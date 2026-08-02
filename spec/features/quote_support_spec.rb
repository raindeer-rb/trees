# frozen_string_literal: true

require_relative '../../lib/trees'

RSpec.describe 'Quote Support' do
  it 'supports quoted strings' do
    expect { system(%(example/cli say "Hello World")) }
      .to output(a_string_including('Hello World'))
      .to_stdout_from_any_process
  end
end
