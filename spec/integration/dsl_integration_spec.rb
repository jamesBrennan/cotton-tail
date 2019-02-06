# frozen_string_literal: true

module CottonTail
  describe 'Defining a CottonTail App' do
    include_context 'rabbitmq_api'

    before do
      watch_start = start_handler
      watch_top = top_handler
      watch_other = other_handler
      watch_named = named_handler

      app.routes.draw do
        queue 'my_app_inbox', exclusive: true do
          topic 'some.topic.prefix' do
            handle 'job.start', watch_start
          end

          handle 'some.top-level.event.happened', watch_top

          handle 'long.running.task' do
            sleep 1
          end

          handle 'my-service.*:resource.*:action', watch_named
        end

        queue 'another_queue', exclusive: true do
          handle 'another.routing.key', watch_other
        end
      end
    end

    let(:app) do
      CottonTail::App.new(connection: connection, queue_strategy: Queue::Memory)
    end

    let(:start_handler) { double('start') }
    let(:top_handler) { double('start') }
    let(:named_handler) { double('named') }
    let(:other_handler) { double('other') }

    it 'runs without errors' do
      expect(app).to be_truthy
    end

    describe 'configuring message queues' do
      describe '.queues' do
        subject(:queues) { app.queues }

        its(:length) { is_expected.to be 2 }

        it 'has members that are queues' do
          expect(queues).to all be_an_instance_of(::Queue)
        end
      end
    end

    describe 'routing topic messages' do
      let(:queue) { app.queues.first }
      let(:other_queue) { app.queues.last }
      let(:env) { app.env }

      it 'sends messages to the expected handler' do
        start_request = build_request('some.topic.prefix.job.start', 'hello!')
        top_request = build_request('some.top-level.event.happened', 'something happened')
        other_request = build_request('another.routing.key', 'hello also')
        named_request = build_request(
          'my-service.user.add', 'added', route_params: { 'resource' => 'user', 'action' => 'add' }
        )

        queue.push start_request
        queue.push top_request
        queue.push named_request
        other_queue.push other_request

        expect(start_handler).to receive(:call).with([env, start_request, Response])
        expect(top_handler).to receive(:call).with([env, top_request, Response])
        expect(other_handler).to receive(:call).with([env, other_request, Response])
        expect(named_handler).to receive(:call).with([env, named_request, Response])

        app.run
      end
    end

    describe 'using middleware' do
      let(:middleware_end_handler) { spy('middleware_end') }

      before do
        app.config.middleware do |m|
          m.use ->((_env, request, _response)) { request.payload.upcase }
          m.use middleware_end_handler
        end

        allow(start_handler).to receive(:call)
        allow(top_handler).to receive(:call)
        allow(named_handler).to receive(:call)
        allow(other_handler).to receive(:call)
      end

      let(:queue) { app.queues.first }
      let(:routing_key) { 'some.topic.prefix.job.start' }
      let(:request) { build_request(routing_key, 'hello!') }

      it 'Applies the middleware' do
        expect(middleware_end_handler).to(
          receive(:call).with('HELLO!')
        )

        queue.push request
        app.run
      end
    end
  end
end

def build_request(routing_key, payload, route_params: {})
  delivery_info = OpenStruct.new(routing_key: routing_key)
  properties = CottonTail::MessageProperties.new(route_params: route_params)
  CottonTail::Request.new(delivery_info, properties, payload)
end
