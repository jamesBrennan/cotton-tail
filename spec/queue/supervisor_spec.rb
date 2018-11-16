# frozen_string_literal: true

module CottonTail
  module Queue
    describe Supervisor do
      subject(:supervisor) { described_class.new(queue) }

      let(:queue) { ::Queue.new }
      let(:middleware) { CottonTail.configuration.middleware }

      describe '.start' do
        subject(:start) { supervisor.start }

        before do
          allow(middleware).to receive(:call).and_return -> { sleep 1 }
        end

        it { is_expected.to be_a_kind_of(Thread) }

        it 'is non blocking' do
          # 10 message on the queue
          10.times.inject(queue, :push)

          # each of which takes 1 second to process
          allow(middleware).to receive(:call).and_return -> { sleep 1 }

          expect { start }.to perform_under(0.1).sec
        end
      end
    end
  end
end
