# frozen_string_literal: true

module CottonTail
  module Queue
    describe Bunny do
      include_context 'rabbitmq_api'

      subject(:queue) { described_class.new(name: name, exclusive: true, connection: connection) }

      let(:name) { '' }

      describe 'push and pulling' do
        let(:routing_key) { 'some.routing.key' }
        let(:delivery_info) { instance_double(::Bunny::DeliveryInfo, routing_key: routing_key) }

        it 'works as expected' do
          queue.push CottonTail::Request.new(delivery_info, {}, 'hello')

          message = queue.pop
          expect(message).to be_a Request
          expect(message.payload).to eql 'hello'
        end
      end
    end
  end
end
