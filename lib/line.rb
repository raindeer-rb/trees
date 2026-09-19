# frozen_string_literal: true

module Trees
  class Line
    attr_reader :path, :params
    attr_accessor :summary, :example, :execute

    def initialize(path:, params: {})
      @path = path
      @params = params

      @summary = nil
      @example = nil
      @execute = nil
    end
  end
end
