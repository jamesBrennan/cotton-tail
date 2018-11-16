# frozen_string_literal: true

describe CottonTail do
  it 'has a version number' do
    expect(CottonTail::VERSION).not_to be nil
  end

  describe '.configuration' do
    subject { described_class.configuration }

    it { is_expected.to be_a CottonTail::Configuration }
  end

  describe '.configure' do
    context 'given a block' do
      it 'yields the configuration instance' do
        expect { |b| described_class.configure(&b) }.to yield_control
      end
    end

    context 'without a block' do
      it 'returns the Configuration instance' do
        expect(described_class.configure).to be_a CottonTail::Configuration
      end
    end
  end
end
