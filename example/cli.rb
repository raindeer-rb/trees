#!/usr/bin/env ruby

require_relative '../lib/trees'

module CLI
  extend Trees

  line('talk') do
    summary { 'Talks to the user.' }
    execute { puts 'Hello' }
  end
end

CLI.run(ARGV)
