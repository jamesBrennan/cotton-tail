# frozen_string_literal: true

module CottonTail
  module Queue
    describe Bunny do
      subject(:queue) { described_class.new(name, exclusive: true) }

      let(:name) { '' }

      describe 'push and pulling' do
        let(:routing_key) { 'some.routing.key' }

        it 'works as expected' do
          queue.push [routing_key, 'hello']

          message = queue.pop

          expect(message).to be_a Array

          key, delivery_info, properties, payload = message

          expect(key).to eql routing_key
          expect(delivery_info).to be_a ::Bunny::DeliveryInfo
          expect(properties).to be_a ::Bunny::MessageProperties
          expect(payload).to eql 'hello'
        end
      end
    end
  end
end
