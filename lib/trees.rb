# frozen_string_literal: true

require_relative 'line'
require_relative 'trie'

module Trees
  attr_reader :lines, :trie

  def line(path, &block)
    current_path << path
    current_line = Line.new(path: current_path.join)

    lines[current_path.join] = current_line
    trie.merge(line: current_line)

    block.call if block_given?

    current_path.pop
  end

  def summary(&block)
    current_line.summary = block
  end

  def execute(&block)
    current_line.execute = block
  end

  def self.run(args)
    binding.irb
    trie.match(args.join(' '))
  end

  private

  def current_path
    @current_path ||= []
  end

  def current_line
    @current_line ||= nil
  end

  def lines
    @lines ||= {}
  end

  def trie
    @trie ||= Trie.new
  end

  # def handle(event:)
  #   response_event = nil

  #   # The last line event will render a response event which we want to return to the request event.
  #   @trie.match(path: event.request.path.delete_suffix('/')).each do |route_event|
  #     response_event = route_event.trigger
  #   end
  #   return response_event if response_event
  # end
end
