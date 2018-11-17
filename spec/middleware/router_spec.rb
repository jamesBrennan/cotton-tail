# frozen_string_literal: true

module CottonTail
  module Middleware
    # Router Middleware
    describe Router do
      subject(:router) { described_class.new(app) }
      let(:app) { spy('app') }

      describe '.call' do
        let(:routing_key) { 'my.test.route' }
        let(:handler) { spy('handler') }
        let(:route_handlers) { Hash[routing_key, handler] }

        before do
          allow(CottonTail.application.routes).to receive(:handlers) { route_handlers }
        end

        context 'when a route is defined' do
          it 'calls the handler' do
            router.call([routing_key, 1, 'two'])
            expect(handler).to have_received(:call).with(1, 'two')
          end
        end

        context 'when route is not defined' do
          it 'raises an error' do
            expect { router.call(['some.unknown.route', 1, 'two']) }
              .to raise_error(UndefinedRouteError)
          end
        end
      end
    end
  end
end
