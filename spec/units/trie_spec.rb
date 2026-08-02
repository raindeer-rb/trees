# frozen_string_literal: true

require_relative '../../lib/line'
require_relative '../../lib/trie'

module Trees
  RSpec.describe Trie do
    subject(:trie) { described_class.new }

    def matching_node(node:, path:)
      return node if node.line&.path == path

      node.nodes.values.map do |child_node|
        matching_node(node: child_node, path:)
      end.compact.first
    end

    describe '#merge' do
      it 'creates a prefix tree of nodes' do
        trie.merge(line: Line.new(path: 'command'))
        trie.merge(line: Line.new(path: 'command :arg'))
        trie.merge(line: Line.new(path: 'command :arg subcommand'))

        expect(trie.root_node.nodes.keys.first).to eq('c')
        expect(trie.root_node.nodes.values.first.nodes.keys.first).to eq('o')
        expect(trie.root_node.nodes.values.first.nodes.values.first.nodes.keys.first).to eq('m')

        expect(matching_node(node: trie.root_node, path: 'command')).to be_truthy
        expect(matching_node(node: trie.root_node, path: 'command :arg')).to be_truthy
        expect(matching_node(node: trie.root_node, path: 'command :arg subcommand')).to be_truthy
      end

      it 'raises error when the path is a duplicate' do
        trie.merge(line: Line.new(path: 'command'))

        expect do
          trie.merge(line: Line.new(path: 'command'))
        end.to raise_error(Trie::DuplicatePathError)
      end
    end

    describe '#match' do
      context 'with a command' do
        it 'matches line' do
          trie.merge(line: Line.new(path: 'command'))
          expect(trie.match(tokens: ['command'])).to all(be_instance_of(Trie::Result))
        end

        it 'does not match a mid node with an end node' do
          trie.merge(line: Line.new(path: 'command'))

          expect(trie.match(tokens: %w[command 1])).to eq([])
        end
      end

      context 'with a command and arg' do
        it 'matches line' do
          trie.merge(line: Line.new(path: 'command :arg'))

          expect(trie.match(tokens: %w[command 1])).to all(be_instance_of(Trie::Result))
          expect(trie.match(tokens: %w[command 1]).first.line).to have_attributes(path: 'command :arg')
        end

        it 'does not split tokens with spaces' do
          trie.merge(line: Line.new(path: 'say :word'))

          result = trie.match(tokens: ['say', 'hello world']).first

          expect(result.line).to have_attributes(path: 'say :word')
          expect(result.params[:word]).to eq('hello world')
        end
      end

      context 'with sub command' do
        before do
          trie.merge(line: Line.new(path: 'command subcommand'))
          trie.merge(line: Line.new(path: 'command subcommand :arg_1'))
        end

        it 'matches lines' do
          expect(trie.match(tokens: %w[command subcommand 1])).to all(be_instance_of(Trie::Result))
          expect(trie.match(tokens: %w[command subcommand 1]).last.line).to have_attributes(path: 'command subcommand :arg_1')
        end
      end

      context 'with top level args' do
        before do
          trie.merge(line: Line.new(path: 'command'))
          trie.merge(line: Line.new(path: 'command subcommand'))
          trie.merge(line: Line.new(path: 'command :arg_1 subcommand'))
          trie.merge(line: Line.new(path: 'command :arg_1 subcommand :arg_2'))
        end

        context 'with one arg' do
          it 'matches line' do
            trie.merge(line: Line.new(path: ':arg_1'))

            expect(trie.match(tokens: ['username']).first.line).to have_attributes(path: ':arg_1')
          end
        end

        context 'with two args' do
          it 'matches line' do
            trie.merge(line: Line.new(path: ':arg_1 :arg_2'))

            expect(trie.match(tokens: %w[username 123]).first.line).to have_attributes(path: ':arg_1 :arg_2')
          end
        end
      end

      context 'with a flag' do
        context 'with a variable' do
          it 'captures the arg after the tag prefix' do
            trie.merge(line: Line.new(path: 'build --env=:env'))

            result = trie.match(tokens: ['build', '--env=prod']).first

            expect(result.line).to have_attributes(path: 'build --env=:env')
            expect(result.params[:env]).to eq('prod')
          end
        end
      end
    end
  end
end
