# frozen_string_literal: true

def build_request(routing_key, payload)
  CottonTail::Request.new({ routing_key: routing_key }, {}, payload)
end

module CottonTail
  describe 'Defining a CottonTail App' do
    include_context 'rabbitmq_api'

    WorkerSpy = Class.new do
      attr_reader :calls

      def initialize
        @calls = []
      end

      def call(args)
        args.tap { @calls << args }
      end

      def reset
        @calls = []
      end
    end

    StartSpy = WorkerSpy.new
    TopSpy = WorkerSpy.new
    OtherSpy = WorkerSpy.new

    before do
      app.routes.draw do
        queue 'my_app_inbox', exclusive: true do
          topic 'some.topic.prefix' do
            handle 'job.start', StartSpy
          end

          handle 'some.top-level.event.happened', TopSpy

          handle 'long.running.task' do
            sleep 1
          end
        end

        queue 'another_queue', exclusive: true do
          handle 'another.routing.key', OtherSpy
        end
      end
    end

    let(:app) do
      CottonTail::App.new(connection: connection, queue_strategy: Queue::Memory)
    end

    let(:start_spy) { spy('start') }
    let(:stop_spy) { spy('stop') }

    it 'runs without errors' do
      expect(app).to be_truthy
    end

    before do
      StartSpy.reset
      TopSpy.reset
      OtherSpy.reset
    end

    describe 'configuring message queues' do
      describe '.queues' do
        subject(:queues) { app.queues }

        its(:length) { is_expected.to be 2 }

        it 'has members that are [name, instance] tuples' do
          name, instance = queues.shift
          expect(name).to eql 'my_app_inbox'
          expect(instance).to be_an_instance_of(::Queue)
        end
      end

      describe '.queue' do
        subject { app.queue('my_app_inbox') }

        it { is_expected.to be_an_instance_of(::Queue) }
      end
    end

    describe 'routing topic messages' do
      let(:queue) { app.queue('my_app_inbox') }
      let(:other_queue) { app.queue('another_queue') }
      let(:env) { app.env }

      it 'sends messages to the expected handler' do
        start_request = build_request('some.topic.prefix.job.start', 'hello!')
        top_request = build_request('some.top-level.event.happened', 'something happened')
        other_request = build_request('another.routing.key', 'hello also')

        queue.push start_request
        queue.push top_request
        other_queue.push other_request

        app.run

        expect(StartSpy.calls).to(
          match([[env, start_request, anything]])
        )

        expect(TopSpy.calls).to(
          match([[env, top_request, anything]])
        )

        expect(OtherSpy.calls).to(
          match([[env, other_request, anything]])
        )
      end
    end

    describe 'using middleware' do
      let(:middleware_end_spy) { spy('middleware_end') }

      before do
        app.config.middleware do |m|
          m.use ->((_env, request, _response)) { request.payload.upcase }
          m.use middleware_end_spy
        end
      end

      let(:queue) { app.queue('my_app_inbox') }
      let(:routing_key) { 'some.topic.prefix.job.start' }
      let(:request) { build_request(routing_key, 'hello!') }

      it 'Applies the middleware' do
        expect(middleware_end_spy).to(
          receive(:call).with('HELLO!')
        )

        queue.push request
        app.run
      end
    end
  end
end