# frozen_string_literal: true

require 'low_type'

module Trees
  class Line
    include LowType

    attr_reader :path, :params
    attr_accessor :summary, :execute

    def initialize(path: String, params: {})
      @path = path
      @params = params

      @summary = nil
      @execute = nil
    end
  end
end
