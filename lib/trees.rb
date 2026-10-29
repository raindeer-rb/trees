# frozen_string_literal: true

require_relative 'flags'
require_relative 'line'
require_relative 'trie'

module Trees
  TOKEN_SEPARATOR = ' '

  def line(path, &block)
    current_path << path
    defined = define_line(block:)

    block.call(**stub_required_keywords(block:)) if block_given?

    defined.keep_defaults
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

  # The tokens match a line as they are, or else its args do, and its flags, in any order, are its keyword arguments.
  def run(tokens)
    return true if execute_block(results: trie.match(tokens:))

    args, flags = Flags.split(tokens)
    return false if flags.nil? || flags.empty?

    execute_block(results: trie.match(tokens: args), flags:)
  end

  private

  # The deepest line that runs, and has a keyword argument for each flag.
  def execute_block(results:, flags: {})
    while results.count > 0
      result = results.pop

      next unless result.line.execute
      next unless (flags.keys - result.line.keywords).empty?

      result.line.run(result.params.merge(flags))
      return true
    end

    false
  end

  def define_line(block:)
    path = current_path.join(TOKEN_SEPARATOR)
    keywords = block.parameters.filter_map { |type, name| name if %i[key keyreq].include?(type) }
    @current_line = Line.new(path:, params: block.parameters.map(&:last), keywords:)

    lines[path] = @current_line
    trie.merge(line: @current_line)
    @current_line
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
