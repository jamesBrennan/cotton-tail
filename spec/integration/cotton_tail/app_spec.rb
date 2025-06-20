# frozen_string_literal: true

# Run specs against RabbitMQ server
module CottonTail
  describe App do
    include_context 'with rabbitmq_api'

    subject(:app) { described_class.new(queue_strategy: queue_strategy) }

    let(:queue_strategy) { CottonTail::Queue::Bunny }

    queue_name = 'integration_test_queue'
    null_handler = -> {}

    before { delete_queues queue_name }
    after { delete_queues queue_name }

    describe 'declaring queues' do
      it 'creates queue if it does not exist' do
        app.routes.draw { queue queue_name }

        expect(queue_name).to exist_on_server
      end
    end

    describe 'queue bindings' do
      it 'creates a binding for each handled route' do
        pattern = 'some.topic.routing.key'

        app.routes.draw do
          queue queue_name do
            handle pattern, null_handler
          end
        end

        expect(queue_name).to have_bindings(pattern)
      end

      it 'binds named wildcards correctly' do
        app.routes.draw do
          queue queue_name do
            handle '*:a.*:b.*:c', null_handler
            handle 'domain.#:resources.fetch', null_handler
          end
        end

        expect(queue_name).to have_bindings('*.*.*', 'domain.#.fetch')
      end

      context 'when called without a queue name' do
        it 'runs without errors' do
          app.routes.draw do
            queue do
              handle 'a.b.c', null_handler
            end
          end

          expect { app.run }.not_to raise_error
        end
      end
    end

    describe 'binding without a handler' do
      it 'is created with the "bind" method' do
        routing_key = 'an.unhandled.binding'

        app.routes.draw do
          queue queue_name do
            bind routing_key
          end
        end

        expect(queue_name).to have_bindings(routing_key)
      end
    end

    describe 'binding the same routing_key to different queues' do
      it 'creates the bindings as expected' do
        routing_key = 'a.b.c'
        other_queue = "#{queue_name}_too"

        app.routes.draw do
          queue queue_name do
            handle routing_key, null_handler
          end

          queue other_queue do
            handle routing_key, null_handler
          end
        end

        expect(queue_name).to have_bindings(routing_key)
        expect(other_queue).to have_bindings(routing_key)
      end
    end

    describe 'handling messages' do
      it 'routes messages to the specified handlers' do
        nested_handler = spy('topic handler')
        top_level_handler = spy('top level handler')
        exclusive_handler = spy('exclusive handler')

        app.routes.draw do
          queue queue_name do
            topic 'some.topic' do
              handle 'work', nested_handler
            end

            handle 'work', top_level_handler
          end

          queue do
            handle 'exclusive.work', exclusive_handler
          end
        end

        publish('nested-message', routing_key: 'some.topic.work')
        publish('top-level-message', routing_key: 'work')
        publish('exclusive-message', routing_key: 'exclusive.work')

        sleep 0.01

        app.run

        expect(nested_handler).to have_received(:call)
        expect(top_level_handler).to have_received(:call)
        expect(exclusive_handler).to have_received(:call)
      end

      it 'routes messages to topics with wildcards' do
        wildcard_handler = spy('wildcard handler')
        query_handler = spy('query handler')

        app.routes.draw do
          queue queue_name do
            topic 'some.topic' do
              handle 'event.*', wildcard_handler
            end

            handle '#.query.*', query_handler
          end
        end

        publish('wildcard message', routing_key: 'some.topic.event.started')
        publish('wildcard message', routing_key: 'some.topic.event.finished')
        publish('query 1', routing_key: 'some.topic.query.run')
        publish('query 2', routing_key: 'query.run')

        sleep 0.01

        app.run

        expect(wildcard_handler).to have_received(:call).exactly(2).times
        expect(query_handler).to have_received(:call).exactly(2).times
      end
    end

    describe '#stop' do
      let(:stop_queue) { 'stop_test_queue' }

      before do
        delete_queues stop_queue

        q = stop_queue # capture local variable
        app.routes.draw do
          queue q do
            handle 'a.b.c', ->(_e, _r, _s) {}
          end
        end
      end

      after { delete_queues stop_queue }

      it 'closes the Bunny connection and stops all supervisors' do
        connection = app.instance_variable_get(:@connection)
        expect(connection).to be_a(Bunny::Session)
        expect(connection).not_to be_closed

        # Process (empty) queue then stop the app
        app.run
        app.stop

        # Connection should now report closed
        expect(connection).to be_closed

        # All supervisors should report not running
        expect(app.send(:supervisors)).to all(satisfy { |sup| !sup.running? })
      end
    end
  end
end
