# frozen_string_literal: true

require_relative 'line'
require_relative 'trie'

module Trees
  TOKEN_SEPARATOR = ' '

  def line(path, &block)
    current_path << path
    current_path_joined = current_path.join(TOKEN_SEPARATOR)

    @current_line = Line.new(path: current_path_joined, params: block.parameters.map(&:last))

    lines[current_path_joined] = @current_line
    trie.merge(line: @current_line)

    block.call(**stub_required_keywords(block:)) if block_given?

    current_path.pop
  end

  def summary(&block)
    @current_line.summary = block
  end
  alias s summary

  def example(&block)
    @current_line.example = block
  end
  alias e example

  def execute(&block)
    @current_line.execute = block
  end
  alias x execute

  def run(tokens)
    results = trie.match(tokens:)
    execute_block(results:)
  end

  private

  def execute_block(results:)
    while results.count > 0
      result = results.pop

      next unless result.line.execute

      result.line.params.each do |param|
        result.line.execute.binding.local_variable_set(param, result.params[param]) if result.params.key?(param)
      end

      result.line.execute.call

      return true
    end

    false
  end

  # The "line" block defines the params that the "execute" child block will use later but doesn't itself execute user input.
  def stub_required_keywords(block:)
    block.parameters.filter_map { |type, name| [name, nil] if type == :keyreq }.to_h
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
