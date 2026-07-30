# frozen_string_literal: true

require 'low_type'

module Trees
  class Line
    include LowType

    attr_reader :path
    attr_accessor :summary, :execute

    def initialize(path: String)
      @path = path

      @summary = nil
      @execute = nil
    end
  end
end
