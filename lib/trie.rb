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

    def match(tokens:, current_node: @root_node, index: 0, offset: 0, params: {})
      return [] if tokens.empty?

      [
        *match_static(tokens:, current_node:, index:, offset:, params:),
        *match_dynamic(tokens:, current_node:, index:, offset:, params:)
      ]
    end

    private

    # Match an input character with the trie or mimic the space character between tokens in the trie.
    def match_static(tokens:, current_node:, index:, offset:, params:)
      child_node = current_node.child(key: tokens[index][offset] || ' ')
      return [] unless child_node

      next_index, next_offset = advance(tokens:, index:, offset:)
      result = full_match(child_node:, tokens:, index: next_index, offset: next_offset, params:)

      [*result, *match(tokens:, current_node: child_node, index: next_index, offset: next_offset, params:)]
    end

    # Dynamic path segment: capture the remainder of the current token.
    def match_dynamic(tokens:, current_node:, index:, offset:, params:)
      current_node.params.flat_map do |param|
        child_node = current_node.child(key: param)
        arg, next_index, next_offset = capture_arg(tokens:, index:, offset:)
        next_params = params.merge(param.delete_prefix(':').to_sym => arg)

        result = full_match(child_node:, tokens:, index: next_index, offset: next_offset, params: next_params)

        [*result, *match(tokens:, current_node: child_node, index: next_index, offset: next_offset, params: next_params)]
      end
    end

    def full_match(child_node:, tokens:, index:, offset:, params:)
      if child_node.line && tokens[index + 1].nil?
        return [Result.new(line: child_node.line, params:)]
      end

      []
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

    def advance(tokens:, index:, offset:)
      token = tokens[index]

      offset < token.length ? [index, offset + 1] : [index + 1, 0]
    end

    def capture_arg(tokens:, index:, offset:)
      token = tokens[index]

      [token[offset..], index, token.length]
    end
  end
end
