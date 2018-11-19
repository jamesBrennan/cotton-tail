# frozen_string_literal: true

module CottonTail
  describe 'Defining a CottonTail App' do
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
      CottonTail.reset
      CottonTail.application(queue_strategy: Queue::Memory).routes.draw do
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

    let(:app) { CottonTail.application }

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
      let(:env) { CottonTail.application.env }

      it 'sends messages to the expected handler' do
        queue.push %w[some.topic.prefix.job.start hello!]
        queue.push ['some.top-level.event.happened', 'something happened']

        other_queue.push ['another.routing.key', 'hello also']

        app.run

        expect(StartSpy.calls).to(
          contain_exactly([env, 'some.topic.prefix.job.start', 'hello!'])
        )

        expect(TopSpy.calls).to(
          contain_exactly([env, 'some.top-level.event.happened', 'something happened'])
        )

        expect(OtherSpy.calls).to(
          contain_exactly([env, 'another.routing.key', 'hello also'])
        )
      end
    end

    describe 'using middleware' do
      let(:middleware_end_spy) { spy('middleware_end') }

      before do
        CottonTail.configuration.middleware do |m|
          m.use ->((_env, _routing_key, message)) { message.upcase }
          m.use middleware_end_spy
        end
      end

      let(:queue) { app.queue('my_app_inbox') }
      let(:routing_key) { 'some.topic.prefix.job.start' }

      it 'Applies the middleware' do
        expect(middleware_end_spy).to receive(:call).with('HELLO !')

        queue.push [routing_key, 'hello !']
        app.run
      end
    end
  end
end
