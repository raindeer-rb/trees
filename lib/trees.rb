# frozen_string_literal: true

require_relative 'line'
require_relative 'trie'

module Trees
  attr_reader :lines, :trie

  TOKEN_SEPARATOR = ' '.freeze

  def line(path, &block)
    current_path << path
    current_path_joined = current_path.join(TOKEN_SEPARATOR)

    @current_line = Line.new(path: current_path_joined, params: block.parameters.to_h)

    lines[current_path_joined] = @current_line
    trie.merge(line: @current_line)

    block.call if block_given?

    current_path.pop
  end

  def summary(&block)
    @current_line.summary = block
  end

  def execute(&block)
    @current_line.execute = block
  end

  def run(tokens)
    results = trie.match(tokens:)

    execute_block(results:)
  end

  private

  def execute_block(results:)
    while results.count > 0
      result = results.pop

      if result.line.execute
        result.line.params.values.each do |param|
          result.line.execute.binding.local_variable_set(param, result.params[param])
        end

        result.line.execute.call

        return true
      end
    end

    false
  end  

  def current_path
    @current_path ||= []
  end

  def lines
    @lines ||= {}
  end

  def trie
    @trie ||= Trie.new
  end
end
