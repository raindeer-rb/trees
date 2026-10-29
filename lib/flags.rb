# frozen_string_literal: true

module Trees
  module Flags
    module_function

    def split(tokens)
      args = tokens.take_while { !flag?(it) }
      flags = tokens.drop(args.length).slice_before { flag?(it) }.map { flag(*it) }
      return if flags.include?(nil)

      [args, flags.to_h]
    end

    # A dash alone, like for stdin, is an arg.
    def flag?(token) = token.start_with?('-') && token != '-'

    def flag(token, *values)
      return if values.size > 1

      name, given = token.sub(/\A--?/, '').split('=', 2)
      [name.tr('-', '_').to_sym, given || values.first || true]
    end
  end
end
