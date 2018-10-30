# frozen_string_literal: true

describe Cotton do
  it 'has a version number' do
    expect(Cotton::VERSION).not_to be nil
  end

  WorkerSpy = Class.new do
    attr_reader :calls

    def initialize
      @calls = []
    end

    def call(*args)
      @calls << args
    end

    def reset
      @calls = []
    end
  end

  StartSpy = WorkerSpy.new
  TopSpy = WorkerSpy.new
  OtherSpy = WorkerSpy.new

  let(:app) do
    Cotton::App.new(**dependencies).define do
      queue 'my_app_inbox' do
        topic 'some.topic.prefix' do
          handle 'job.start', StartSpy
        end

        handle 'some.top-level.event.happened', TopSpy

        handle 'long.running.task' do
          sleep 1
        end
      end

      queue 'another_queue' do
        handle 'another.routing.key', OtherSpy
      end
    end
  end

  let(:start_spy) { spy('start') }
  let(:stop_spy) { spy('stop') }

  let(:dependencies) do
    {
      queue_strategy: Cotton::Queue::Memory,
      routing_strategy: Cotton::Router
    }
  end

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
        expect(instance).to be_an_instance_of(Queue)
      end
    end

    describe '.queue' do
      subject { app.queue('my_app_inbox') }

      it { is_expected.to be_an_instance_of(Queue) }
    end
  end

  describe 'routing topic messages' do
    let(:queue) { app.queue('my_app_inbox') }
    let(:other_queue) { app.queue('another_queue') }

    it 'sends messages to the expected handler' do
      queue.push %w[some.topic.prefix.job.start hello!]
      queue.push ['some.top-level.event.happened', 'something happened']

      other_queue.push ['another.routing.key', 'hello also']

      app.run

      expect(StartSpy.calls).to contain_exactly ['hello!']
      expect(TopSpy.calls).to contain_exactly ['something happened']
      expect(OtherSpy.calls).to contain_exactly ['hello also']
    end
  end
end
