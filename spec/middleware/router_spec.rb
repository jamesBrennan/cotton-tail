# frozen_string_literal: true

module CottonTail
  module Middleware
    # Router Middleware
    describe Router do
      subject(:router) { described_class.new(input) }
      let(:input) { spy('message') }

      let(:app) { instance_double(App, routes: routes, env: env) }
      let(:routes) { instance_double(DSL::Routes, handlers: route_handlers) }
      let(:env) { 'env' }

      describe '.call' do
        let(:routing_key) { 'my.test.route' }
        let(:handler) { spy('handler') }
        let(:route_handlers) { Hash[routing_key, handler] }

        context 'when a route is defined' do
          it 'calls the handler' do
            router.call([app, routing_key, 1, 'two'])
            expect(handler).to have_received(:call).with([env, routing_key, 1, 'two'])
          end
        end

        context 'when route is not defined' do
          it 'raises an error' do
            expect { router.call([app, 'some.unknown.route', 1, 'two']) }
              .to raise_error(UndefinedRouteError)
          end
        end
      end
    end
  end
end
