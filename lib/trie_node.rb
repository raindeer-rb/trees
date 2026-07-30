# frozen_string_literal: true

require_relative 'line'

module Trees
  class TrieNode
    include LowType
    using LowType::Syntax

    # TODO: Represent empty hash/array return value as {}/[] rather than Hash/Array (https://github.com/low-rb/low_type/issues/16)
    type_reader nodes: Hash[String => TrieNode] | Hash
    type_reader params: Array[String] | Array
    type_accessor line: Line | nil

    def initialize
      @nodes = {}
      @params = []
      @line = nil
    end

    def child(key: String)
      @nodes[key]
    end

    def upsert_child(key: String)
      @params << key if key.start_with?(':')
      @nodes[key] || @nodes[key] = TrieNode.new
    end
  end
end
