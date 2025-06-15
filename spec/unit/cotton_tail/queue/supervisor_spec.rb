# frozen_string_literal: true

module CottonTail
  module Queue
    describe Supervisor do
      subject(:supervisor) { described_class.new(queue, app: app) }

      let(:queue) { ::Queue.new }
      let(:app) { instance_double(App, config: config, env: {}) }
      let(:config) { instance_double(Configuration, middleware: middleware) }
      let(:middleware) { instance_double(Proc, 'middleware stack') }

      describe '.start' do
        subject(:start) { supervisor.start }

        before do
          allow(middleware).to receive(:call).and_return -> { sleep 1 }
        end

        it { is_expected.to be_a(Thread) }

        it 'is non blocking' do
          # 10 message on the queue
          10.times.inject(queue, :push)

          expect { start }.to perform_under(0.1).sec
        end
      end
    end
  end
end
