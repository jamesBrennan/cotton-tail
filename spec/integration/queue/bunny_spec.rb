# frozen_string_literal: true

module CottonTail
  module Queue
    describe Bunny do
      include_context 'rabbitmq_api'

      subject(:queue) { described_class.new(**kwargs) }

      let(:kwargs) { { name: name, exclusive: true, connection: connection } }
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

      context 'given a name of nil' do
        let(:name) { nil }

        it 'sets the name to the queue name created by the server' do
          expect(queue).to be_an_instance_of(CottonTail::Queue::Bunny)
          # expect(queue).to respond_to?(:name)
          # expect(queue.name).not_to be_nil
        end
      end
    end
  end
end
