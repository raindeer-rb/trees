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

    context 'with keyword arguments' do
      it 'sets block params' do
        captured_vars = nil

        cli.line('render :path') do
          cli.line('-o :output') do |path:, output:|
            cli.execute { captured_vars = [path, output] }
          end
        end

        cli.run(%w[render a.md -o a.html])

        expect(captured_vars).to eq(['a.md', 'a.html'])
      end
    end

    context 'with default values' do
      it 'supports default values in params' do
        captured_vars = nil

        cli.line('render :path') do |path, format = 'html', output: nil, verbose: false|
          cli.execute { captured_vars = [path, format, output, verbose] }
        end

        cli.run(%w[render a.md])

        expect(captured_vars).to eq(['a.md', 'html', nil, false])
      end
    end

    context 'with flags' do
      it 'sets keyword arguments named after them, with underscores, in any order, after the args' do
        runs = []
        cli.line('build :path') do |path, bare: false, dry_run: false, x: false|
          cli.execute { runs << [path, bare, dry_run, x] }
        end

        [%w[build a.md --bare -x], %w[build a.md --dry-run --bare], %w[build a.md]].each { cli.run(it) }

        expect(runs).to eq([['a.md', true, false, true], ['a.md', true, true, false], ['a.md', false, false, false]])
      end

      it 'takes the token after a flag, or after its "=", as its value' do
        runs = []
        cli.line('render :path') { |path, output: nil, env: nil| cli.execute { runs << [path, output, env] } }

        [%w[render a.md --env=prod --output a.html], %w[render a.md --output a.html --env prod]].each { cli.run(it) }

        expect(runs).to eq([%w[a.md a.html prod]] * 2)
      end

      it 'matches no line with a flag it has no keyword argument for, or a flag with two values' do
        cli.line('build :path') { |path, bare: false| cli.execute { [path, bare] } }

        expect([%w[build a.md --nope], %w[build a.md --bare one two]].map { cli.run(it) }).to eq([false, false])
      end

      it 'reads a dash alone as an arg' do
        runs = []
        cli.line('cat :path') { |path, number: false| cli.execute { runs << [path, number] } }

        cli.run(%w[cat - --number])

        expect(runs).to eq([['-', true]])
      end
    end
  end
end
