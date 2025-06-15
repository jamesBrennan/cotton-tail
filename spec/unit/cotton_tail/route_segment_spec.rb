# frozen_string_literal: true

module CottonTail
  describe RouteSegment do
    subject(:segment) { described_class.new(definition) }

    describe '.star?' do
      subject { segment.star? }

      context 'given "*"' do
        let(:definition) { '*' }

        it { is_expected.to be true }
      end

      context 'given "*:named"' do
        let(:definition) { '*:named' }

        it { is_expected.to be true }
      end

      context 'given anything else' do
        let(:definition) { 'hel*o' }

        it { is_expected.to be false }
      end
    end

    describe '.hash?' do
      subject { segment.hash? }

      context 'given "#"' do
        let(:definition) { '#' }

        it { is_expected.to be true }
      end

      context 'given "#:named"' do
        let(:definition) { '#:named' }

        it { is_expected.to be true }
      end

      context 'given anything else' do
        let(:definition) { 'hel#o' }

        it { is_expected.to be false }
      end
    end

    describe '.match?' do
      context 'given a string definition' do
        let(:definition) { 'some-string' }

        it 'matches on string equality' do
          expect(segment.match?('some-string')).to be true

          expect(segment.match?('anything-else')).to be false
          expect(segment.match?(nil)).to be false
          expect(segment.match?(1)).to be false
          expect(segment.match?({})).to be false
        end
      end

      context 'given an anonymous single wildcard definition' do
        let(:definition) { '*' }

        it 'matches any non-empty string without a "." character' do
          expect(segment.match?('any string')).to be true

          expect(segment.match?('my.string')).to be false
          expect(segment.match?('')).to be false
          expect(segment.match?(nil)).to be false
          expect(segment.match?(1)).to be false
          expect(segment.match?({})).to be false
        end
      end

      context 'given an anonymous group wildcard definition' do
        let(:definition) { '#' }

        it 'matches any non-empty string' do
          expect(segment.match?('any string')).to be true
          expect(segment.match?('any.string.value')).to be true

          expect(segment.match?('')).to be false
          expect(segment.match?(nil)).to be false
          expect(segment.match?(1)).to be false
          expect(segment.match?({})).to be false
        end
      end

      context 'given a named single wildcard definition' do
        let(:definition) { '*:foo' }

        it 'matches any non-empty string without a "." character' do
          expect(segment.match?('any string')).to be true

          expect(segment.match?('my.string')).to be false
          expect(segment.match?('')).to be false
          expect(segment.match?(nil)).to be false
          expect(segment.match?(1)).to be false
          expect(segment.match?({})).to be false
        end
      end

      context 'given a named wildcard definition' do
        let(:definition) { '#:foo' }

        it 'matches any non-empty string' do
          expect(segment.match?('any string')).to be true
          expect(segment.match?('any.string.value')).to be true

          expect(segment.match?('')).to be false
          expect(segment.match?(nil)).to be false
          expect(segment.match?(1)).to be false
          expect(segment.match?({})).to be false
        end
      end
    end
  end
end
