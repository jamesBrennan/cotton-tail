# frozen_string_literal: true

module CottonTail
  describe Configuration do
    subject(:configuration) { described_class.new }

    it { is_expected.to respond_to :connection_args }

    describe 'specifying .connection_args' do
      subject { configuration.connection_args }

      let(:set_connection_args) { configuration.connection_args = value }

      describe 'valid values' do
        before { set_connection_args }

        context 'given a URI' do
          let(:value) { 'amqps://example:1234' }

          it { is_expected.to match hash_including(scheme: 'amqps', host: 'example', port: 1234) }
        end

        context 'given a Hash' do
          let(:value) do
            {
              host: 'example',
              port: 5672
            }
          end

          it { is_expected.to match hash_including(host: 'example', port: 5672) }
        end
      end

      describe 'validations' do
        context 'given a malformed URI' do
          let(:value) { "I'm not a URI" }

          it 'raises an InvalidURIError' do
            expect { set_connection_args }.to raise_error(URI::InvalidURIError)
          end
        end

        context 'given a well formed URI with an invalid scheme' do
          let(:value) { 'http://localhost' }

          it 'raises an ArgumentError' do
            expect { set_connection_args }.to raise_error(ArgumentError)
          end
        end
      end
    end

    describe '.middleware' do
      subject(:middleware) { configuration.middleware }

      it { is_expected.to be nil }

      let(:stack_length) do
        -> { configuration.middleware ? configuration.middleware.send(:stack).length : 0 }
      end

      describe 'specifying new middleware' do
        it 'adds the given middleware to the stack' do
          expect { configuration.middleware { |d| d.use ->(x) { puts x } } }
            .to change(&stack_length).by(1)
        end
      end

      describe 'calling middleware multiple times with block' do
        it 'adds the middleware' do
          expect do
            configuration.middleware { |d| d.use ->(x) { puts x } }
            configuration.middleware { |d| d.use ->(x) { puts x } }
          end.to change(&stack_length).by(2)
        end
      end
    end

    describe 'arbitrary configurations' do
      it 'can be set and retrieved' do
        expect { configuration.foo = 'bar' }.to(
          change { configuration.respond_to?(:foo) }.from(false).to(true)
        )

        expect(configuration.foo).to eql 'bar'

        configuration.foo = 'baz'
        expect(configuration.foo).to eql 'baz'
      end
    end
  end
end
