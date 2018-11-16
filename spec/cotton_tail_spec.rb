# frozen_string_literal: true

describe CottonTail do
  it 'has a version number' do
    expect(CottonTail::VERSION).not_to be nil
  end

  before { CottonTail.reset }

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

  describe '.application' do
    it 'returns an instance of Application' do
      expect(described_class.application).to be_a CottonTail::App
    end

    it 'accepts constructor arguments for the CottonTail::App' do
      kwargs = { some: 'args' }
      expect(CottonTail::App).to receive(:new).with(**kwargs)

      described_class.application(**kwargs)
    end

    it 'raises an error when called with constructor arguments more than once' do
      allow(CottonTail::App).to receive(:new) { instance_double(CottonTail::App) }

      # First call instantiates the memoized App instance
      described_class.application(some: 'args')

      # This is ok - gets the previously defined instance
      described_class.application

      # This could cause unexpected behaviour - raise error
      expect do
        described_class.application(other: 'args')
      end.to raise_exception(CottonTail::AppInstantiationError)
    end
  end
end
