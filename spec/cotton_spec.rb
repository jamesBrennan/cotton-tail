# frozen_string_literal: true

require 'spec_helper'

describe Cotton do
  it 'has a version number' do
    expect(Cotton::VERSION).not_to be nil
  end

  WorkerSpy = Class.new do
    attr_reader :calls, :name

    def initialize(name)
      @calls = []
      @name = name
    end

    def call(*args)
      @calls << args
    end

    def reset
      @calls = []
    end
  end

  StartSpy = WorkerSpy.new('job.start')
  TopSpy = WorkerSpy.new('some.top-level.event')

  let(:app) do
    Cotton::App.new(**dependencies).define do
      queue 'my_app_inbox' do
        topic 'some.topic.prefix' do
          handle 'job.start', StartSpy
        end

        handle 'some.top-level.event.happened', TopSpy
      end
    end
  end

  let(:start_spy) { spy('start') }
  let(:stop_spy) { spy('stop') }

  let(:dependencies) do
    {
      queue_strategy: Cotton::Queue,
      routing_strategy: Cotton::Router
    }
  end

  it 'runs without errors' do
    expect(app).to be_truthy
  end

  before do
    StartSpy.reset
    TopSpy.reset
  end

  describe 'configuring message queues' do
    describe '.queues' do
      subject(:queues) { app.queues }

      its(:length) { is_expected.to be 1 }

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

    it 'sends messages to the expected handler' do
      queue.push %w[some.topic.prefix.job.start hello!]
      queue.push ['some.top-level.event.happened', 'something happened']

      app.run

      expect(StartSpy.calls).to contain_exactly ['hello!']
      expect(TopSpy.calls).to contain_exactly ['something happened']
    end
  end
end
