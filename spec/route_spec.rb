# frozen_string_literal: true

module CottonTail
  describe Route do
    subject(:route) { described_class.new(pattern) }

    describe '.match?' do
      context 'given an exchange_type: :topic' do
        let(:opts) { { exchange_type: :topic } }

        describe 'exact matches' do
          let(:pattern) { 'a.b.c' }

          it 'behaves as expected' do
            expect(route.match?('a.b.c')).to be true
            expect(route.match?('a.b.c.d')).to be false
            expect(route.match?('a.b')).to be false
            expect(route.match?('b.c')).to be false
          end
        end

        describe 'wildcard matches' do
          describe 'segment wildcard at end' do
            let(:pattern) { 'a.b.*' }

            it 'behaves as expected' do
              expect(route.match?('a.b.c')).to be true
              expect(route.match?('a.b.z')).to be true
              expect(route.match?('a.b')).to be false
              expect(route.match?('a.b.c.d')).to be false
            end
          end

          describe 'segment wildcard at start' do
            let(:pattern) { '*.b.c' }

            it 'behaves as expected' do
              expect(route.match?('a.b.c')).to be true
              expect(route.match?('z.b.c')).to be true
              expect(route.match?('b.c')).to be false
              expect(route.match?('a.b.z')).to be false
            end
          end

          describe 'multiple segment wildcards' do
            let(:pattern) { '*.b.*.d' }

            it 'behaves as expected' do
              expect(route.match?('a.b.c.d')).to be true
              expect(route.match?('z.b.x.d')).to be true
              expect(route.match?('a.b.c')).to be false
              expect(route.match?('b.c.d')).to be false
            end
          end

          describe 'group wildcard at start' do
            let(:pattern) { '#.d' }

            it 'behaves as expected' do
              expect(route.match?('c.d')).to be true
              expect(route.match?('a.b.c.d')).to be true
              expect(route.match?('d.e')).to be false
              expect(route.match?('a.b.c')).to be false
            end
          end
        end
      end
    end
  end
end
