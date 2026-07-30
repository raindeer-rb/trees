# frozen_string_literal: true

require_relative 'line'
require_relative 'trie_node'

module Trees
  class Trie
    include LowType

    PARAM_DELIMITERS = [' ', ':'].freeze
    ARG_DELIMITERS = [' '].freeze

    attr_reader :root_node

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

      current_node.line = line
    end

    def match(path:, current_node: @root_node, current_index: 0, params: {})
      return [] if (key = path[current_index]).nil?

      blocks = []

      # Static path segment.
      if (child_node = current_node.child(key:))
        blocks << child_node.line if child_node.line
        blocks = [*blocks, *match(path:, current_node: child_node, current_index: current_index + 1, params:)]
      end

      # Dynamic path segment.
      current_node.params.each do |param|
        child_node = current_node.child(key: param)

        arg, next_index = capture_arg(start_index: current_index, path:)
        params[param.delete_prefix(':').to_sym] = arg

        blocks << child_node.line if child_node.line
        blocks = [*blocks, *match(path:, current_node: child_node, current_index: next_index, params:)]
      end

      blocks
    end

    private

    def capture_param(path:)
      param = [':']

      path[@current_index...path.length].chars.each do |char|
        break if PARAM_DELIMITERS.include?(char)

        @current_index += 1
        param << char
      end

      param.join
    end

    def capture_arg(start_index:, path:)
      next_index = start_index
      arg = []

      path[start_index...path.length].chars.each do |char|
        arg << char
        next_index += 1
        break if path[next_index].nil? || ARG_DELIMITERS.include?(path[next_index])
      end

      [arg.join, next_index]
    end
  end
end
