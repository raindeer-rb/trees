# frozen_string_literal: true

require_relative '../../lib/trees'

RSpec.describe Trees do
  subject(:cli) { Module.new.extend(described_class) }

  describe '#execute' do
    it 'sets block params' do
      captured_vars = nil

      cli.line('copy :from :to') do |from, to|
        cli.execute { captured_vars = [from, to] }
      end

      cli.run(%w[copy a.md b.md])

      expect(captured_vars).to eq(['a.md', 'b.md'])
    end

    context 'with sub command' do
      it 'sets block params' do
        captured_vars = nil

        cli.line('render :path') do
          cli.line('-o :output') do |path, output|
            cli.execute { captured_vars = [path, output] }
          end
        end

        cli.run(%w[render a.md -o a.html])

        expect(captured_vars).to eq(['a.md', 'a.html'])
      end
    end
    end
  end
end
