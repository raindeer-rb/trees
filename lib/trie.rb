# frozen_string_literal: true

require_relative 'line'
require_relative 'trie_node'

module Trees
  class Trie
    include LowType

    PARAM_DELIMITERS = [' ', ':'].freeze

    attr_reader :root_node

    Result = Data.define(:line, :params)

    class DuplicatePathError < StandardError; end

    def initialize
      @root_node = TrieNode.new
    end

    def merge(line:, current_node: @root_node)
      @current_index = 0
      path = line.path

      while @current_index < path.length
        key = path[@current_index]

        @current_index += 1

        # Sometimes the key is an entire variable name.
        key = capture_param(path:) if key == ':'

        current_node = current_node.upsert_child(key:)
      end

      raise DuplicatePathError, "Path already defined: #{line.path}" if current_node.line

      current_node.line = line
    end

    def match(args:, current_node: @root_node, token_index: 0, offset: 0, params: {})
      return [] if args.empty?
      return [] if current_key(args:, token_index:, offset:).nil?

      [
        *match_static(args:, current_node:, token_index:, offset:, params:),
        *match_dynamic(args:, current_node:, token_index:, offset:, params:)
      ]
    end

    private

    # Static path segment: match a single character (real, or the synthetic
    # ' ' separator that sits between tokens in the merged trie).
    def match_static(args:, current_node:, token_index:, offset:, params:)
      key = current_key(args:, token_index:, offset:)
      child_node = current_node.child(key:)
      return [] unless child_node

      next_token_index, next_offset = advance(args:, token_index:, offset:)
      result = full_match(child_node:, args:, token_index: next_token_index, offset: next_offset, params:)

      [*result, *match(args:, current_node: child_node, token_index: next_token_index, offset: next_offset, params:)]
    end

    # Dynamic path segment: capture the remainder of the current token.
    def match_dynamic(args:, current_node:, token_index:, offset:, params:)
      current_node.params.flat_map do |param|
        child_node = current_node.child(key: param)
        arg, next_token_index, next_offset = capture_arg(args:, token_index:, offset:)
        next_params = params.merge(param.delete_prefix(':').to_sym => arg)

        result = full_match(child_node:, args:, token_index: next_token_index, offset: next_offset, params: next_params)

        [*result, *match(args:, current_node: child_node, token_index: next_token_index, offset: next_offset, params: next_params)]
      end
    end

    def full_match(child_node:, args:, token_index:, offset:, params:)
      return [] unless child_node.line
      return [] unless current_key(args:, token_index:, offset:).nil?

      [Result.new(line: child_node.line, params:)]
    end

    def capture_param(path:)
      param = [':']

      path[@current_index...path.length].chars.each do |char|
        break if PARAM_DELIMITERS.include?(char)

        @current_index += 1
        param << char
      end

      param.join
    end

    # Returns the next character to match against the trie: a real character
    # from within the current token, a synthetic ' ' representing the
    # boundary between two tokens (mirroring the literal space the trie was
    # built with), or nil once every token has been fully consumed.
    def current_key(args:, token_index:, offset:)
      return nil if token_index >= args.length

      token = args[token_index]
      return token[offset] if offset < token.length
      return nil if token_index == args.length - 1

      ' '
    end

    def advance(args:, token_index:, offset:)
      token = args[token_index]

      offset < token.length ? [token_index, offset + 1] : [token_index + 1, 0]
    end

    # A dynamic segment always captures the rest of the current token as-is
    # (never re-splitting on whitespace), so a token that already contains a
    # space -- e.g. a quoted shell argument -- is preserved intact.
    def capture_arg(args:, token_index:, offset:)
      token = args[token_index]

      [token[offset..], token_index, token.length]
    end
  end
end
