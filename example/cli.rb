#!/usr/bin/env ruby

require_relative '../lib/trees'

module CLI
  extend Trees

  line('say :word') do |word|
    summary { 'Talks to the user.' }
    execute { puts word }
  end
end

CLI.run(ARGV)
