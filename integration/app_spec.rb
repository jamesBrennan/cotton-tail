# frozen_string_literal: true

require 'integration_helper'

# Run specs against RabbitMQ server
module CottonTail
  describe App do
    include_context 'rabbitmq_api'

    subject(:app) { described_class.new(queue_strategy: queue_strategy) }

    let(:queue_strategy) { CottonTail::Queue::Bunny }

    queue_name = 'integration_test_queue'
    null_handler = -> {}

    before { delete_queues queue_name }
    after { delete_queues queue_name }

    describe 'declaring queues' do
      it 'creates queue if it does not exist' do
        app.define { queue queue_name }

        expect(queue_name).to exist_on_server
      end
    end

    describe 'amqp bindings' do
      it 'creates a binding for each handled route' do
        routing_key = 'some.topic.routing.key'

        app.define do
          queue queue_name do
            handle routing_key, null_handler
          end
        end

        expect(queue_name).to have_bindings(routing_key)
      end
    end

    describe 'handling messages' do
      it 'routes messages to the specified handlers' do
        nested_handler = spy('topic handler')
        top_level_handler = spy('top level handler')

        app.define do
          queue queue_name do
            topic 'some.topic' do
              handle 'work', nested_handler
            end

            handle 'work', top_level_handler
          end
        end

        queue = app.queue(queue_name)
        queue.push %w[some.topic.work nested-message]
        queue.push %w[work top-level-message]
        app.run

        expect(nested_handler).to have_received(:call).with(
          anything, anything, 'nested-message', conn: an_instance_of(Queue::Connection)
        )

        expect(top_level_handler).to have_received(:call).with(
          anything, anything, 'top-level-message', conn: an_instance_of(Queue::Connection)
        )
      end

      describe 'requiring acknowledgement' do
        it 'provides ack and nack through a Queue::Connection, passed with the :conn keyword' do
          AckHandler = Class.new do
            def self.call(delivery_info, _properties, _message, **kwargs)
              conn = kwargs.fetch(:conn)
              conn.ack(delivery_info[:delivery_tag])
            end
          end

          NackHandler = Class.new do
            def self.call(delivery_info, _props, _msg, **kwargs)
              conn = kwargs.fetch(:conn)
              conn.nack(delivery_info[:delivery_tag])
            end
          end

          conn = Queue::Connection.new
          expect(conn).to receive(:ack).and_call_original
          expect(conn).to receive(:nack).and_call_original

          app.define do
            queue queue_name, conn: conn, manual_ack: true do
              handle 'must.ack', AckHandler
              handle 'must.nack', NackHandler
            end
          end

          queue = app.queue(queue_name)
          queue.push %w[must.ack some-message]
          queue.push %w[must.nack some-message]
          app.run
        end
      end
    end
  end
end
