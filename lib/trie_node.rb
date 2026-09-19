# frozen_string_literal: true

require_relative 'line'

module Trees
  class TrieNode
    attr_reader :nodes, :params, :line
    attr_accessor :line

    def initialize
      @nodes = {}
      @params = []
      @line = nil
    end

    def child(key:)
      @nodes[key]
    end

    def upsert_child(key:)
      @params << key if key.start_with?(':')
      @nodes[key] || @nodes[key] = TrieNode.new
    end
  end
end
