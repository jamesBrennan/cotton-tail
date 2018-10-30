# frozen_string_literal: true

module Cotton
  describe QueueSupervisor do
    subject(:supervisor) { described_class.new(queue, on_message: router) }

    let(:queue) { ::Queue.new }
    let(:router) { instance_double(Router) }

    describe '.start' do
      subject(:start) { supervisor.start }

      before do
        allow(router).to receive(:call).and_return -> { sleep 1 }
      end

      it { is_expected.to be_a_kind_of(Thread) }

      it 'is non blocking' do
        # 10 message on the queue
        10.times.inject(queue, :push)

        # each of which takes 1 second to process
        allow(router).to receive(:dispatch).and_return -> { sleep 1 }

        expect { start }.to perform_under(0.1).sec
      end
    end
  end
end
