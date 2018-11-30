# frozen_string_literal: true

module CottonTail
  module Queue
    describe Bunny do
      subject(:queue) { described_class.new(name: name, exclusive: true, connection: connection) }

      let(:name) { '' }
      let(:connection) { ::Bunny.new.start }

      describe 'push and pulling' do
        let(:routing_key) { 'some.routing.key' }

        it 'works as expected' do
          queue.push CottonTail::Request.new({ routing_key: routing_key }, {}, 'hello')

          message = queue.pop
          expect(message).to be_a Request
          expect(message.payload).to eql 'hello'
        end
      end
    end
  end
end
