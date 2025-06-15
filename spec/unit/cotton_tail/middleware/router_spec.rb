# frozen_string_literal: true

module CottonTail
  module Middleware
    # Router Middleware
    describe Router do
      subject(:router) { described_class.new(app, handlers: route_handlers) }

      let(:env) { {} }
      let(:request) { CottonTail::Request.new(delivery_info, properties, payload) }
      let(:properties) { MessageProperties.new({}) }
      let(:response) { CottonTail::Response.new }

      let(:delivery_info) { instance_double(Bunny::DeliveryInfo, routing_key: routing_key) }
      let(:message) { [env, request, response] }

      let(:app) { instance_double(Proc, 'middleware app') }

      describe '.call' do
        let(:payload) { 'payload' }

        context 'when a route is defined' do
          let(:routing_key) { 'my.test.route' }
          let(:handler) { instance_double(Proc, 'handler') }
          let(:route) { Route.new(routing_key) }
          let(:route_handlers) { { route => handler } }

          before do
            allow(handler).to receive(:call)
            allow(app).to receive(:call)
            router.call(message)
          end

          # rubocop:disable RSpec/ExampleLength
          it 'calls the handler and then calls app with the handler response' do
            expect(handler).to have_received(:call) do |handler_env, handler_req, handler_res|
              expect(handler_env).to eql env
              expect(handler_req).to be_a Request
              expect(handler_res).to eql response
              'return val'
            end

            expect(app).to have_received(:call) do |next_env, next_req, next_res|
              expect(next_env).to eql env
              expect(next_req).to eql request
              expect(next_res).to match(Response.new('return val'))
            end
          end
          # rubocop:enable RSpec/ExampleLength
        end

        context 'when multiple routes are defined' do
          let(:wildcard_handler) { instance_double(Proc, 'wildcard handler', call: 'wildcard') }
          let(:exact_handler) { instance_double(Proc, 'exact handler', call: 'exact') }

          let(:route_handlers) do
            { Route.new('a.b.*') => wildcard_handler, Route.new('a.b.c') => exact_handler }
          end

          let(:routing_key) { 'a.b.c' }

          it 'raises a RouteConflictError' do
            expect { router.call(message) }.to raise_error(RouteConflictError)
          end
        end

        context 'when route is not defined' do
          let(:routing_key) { 'some.unknown.route' }
          let(:route_handlers) { {} }

          it 'raises an error' do
            expect { router.call(message) }.to raise_error(UndefinedRouteError)
          end
        end
      end

      describe 'parsing route params' do
        let(:payload) { 'payload' }

        let(:route_definition) { '*:domain.*:resource.*:action' }
        let(:routing_key) { 'company.user.add' }
        let(:handler) { instance_double(Proc, 'handler') }
        let(:route) { Route.new(route_definition) }
        let(:route_handlers) { { route => handler } }

        before do
          allow(app).to receive(:call)
          allow(handler).to receive(:call)
        end

        it 'calls the handler' do
          route_params = {
            'domain' => 'company',
            'resource' => 'user',
            'action' => 'add'
          }

          router.call(message)

          expect(handler).to have_received(:call) do |_env, req, _res|
            expect(req.route_params).to match(route_params)
          end
        end

        context 'given a group wildcard at the beginning of a route' do
          let(:route_definition) { '#.*:resource.*:action' }
          let(:routing_key) { 'user.add' }

          before do
            allow(handler).to receive(:call)
            router.call(message)
          end

          it 'routes correctly' do
            expect(handler).to have_received(:call)
          end
        end
      end
    end
  end
end
