# frozen_string_literal: true

module CottonTail
  describe Request do
    subject(:request) { described_class.new(delivery_info, properties, payload) }

    let(:delivery_info) { instance_double(Bunny::DeliveryInfo) }
    let(:properties) { MessageProperties.new({}) }
    let(:payload) { {} }

    describe '.routing_key' do
      subject { request.routing_key }

      before do
        allow(delivery_info).to receive(:routing_key).and_return('some-key')
      end

      it { is_expected.to eql 'some-key' }
    end

    describe '.delivery_tag' do
      subject { request.delivery_tag }

      before do
        allow(delivery_info).to receive(:delivery_tag).and_return('some-tag')
      end

      it { is_expected.to eql 'some-tag' }
    end

    describe '.channel' do
      subject { request.channel }

      before do
        allow(delivery_info).to receive(:channel).and_return('some-channel')
      end

      it { is_expected.to eql 'some-channel' }
    end

    describe '.route_params' do
      subject { request.route_params }

      let(:properties) { MessageProperties.new(route_params: { 'foo' => 'bar' }) }

      it { is_expected.to eql properties[:route_params] }
    end
  end
end
