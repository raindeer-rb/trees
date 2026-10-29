# frozen_string_literal: true

module Trees
  class Line
    attr_reader :path, :params, :keywords
    attr_accessor :summary, :example, :execute

    def initialize(path:, params: [], keywords: [])
      @path = path
      @params = params
      @keywords = keywords

      @summary = nil
      @example = nil
      @execute = nil
      @defaults = {}
    end

    # The keyword arguments' values once the line's defined, which are their defaults, kept so that a flag that isn't
    # given on a run is its default again, rather than its value from the last run.
    def keep_defaults
      @defaults = keywords.to_h { [it, execute.binding.local_variable_get(it)] } if execute
    end

    # Sets the execute block's params to the values, or else the keyword arguments' defaults, then runs it.
    def run(values)
      values = @defaults.merge(values)
      params.each { |param| execute.binding.local_variable_set(param, values[param]) if values.key?(param) }
      execute.call
    end
  end
end
