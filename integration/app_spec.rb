# frozen_string_literal: true

require 'integration_helper'

# Run specs against RabbitMQ server
module Cotton
  describe App do
    include_context 'rabbitmq_api'

    subject(:app) { described_class.new(queue_strategy: queue_strategy) }

    let(:queue_strategy) { Cotton::Queue::Bunny }

    queue_name = 'integration_test_queue'
    null_handler = -> {}

    before { delete_queues queue_name }

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

        expect(nested_handler).to have_received(:call).with(anything, anything, 'nested-message')
        expect(top_level_handler).to have_received(:call).with(anything, anything, 'top-level-message')
      end
    end
  end
end
