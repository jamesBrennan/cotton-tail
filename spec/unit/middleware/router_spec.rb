# frozen_string_literal: true

module CottonTail
  module Middleware
    # Router Middleware
    describe Router do
      subject(:router) { described_class.new(app, handlers: route_handlers) }

      let(:env) { Hash[] }
      let(:request) { CottonTail::Request.new(delivery_info, properties, payload) }
      let(:properties) { MessageProperties.new({}) }
      let(:response) { CottonTail::Response.new }

      let(:delivery_info) { instance_double(Bunny::DeliveryInfo, routing_key: routing_key) }
      let(:message) { [env, request, response] }

      let(:app) { double('middleware app') }

      describe '.call' do
        let(:payload) { 'payload' }

        context 'when a route is defined' do
          let(:routing_key) { 'my.test.route' }
          let(:handler) { double('handler') }
          let(:route) { Route.new(routing_key) }
          let(:route_handlers) { Hash[route, handler] }

          it 'calls the handler and then calls app with the handler response' do
            expect(handler).to receive(:call) do |handler_env, handler_req, handler_res|
              expect(handler_env).to eql env
              expect(handler_req).to be_a Request
              expect(handler_res).to eql response
              'return val'
            end

            expect(app).to receive(:call) do |next_env, next_req, next_res|
              expect(next_env).to eql env
              expect(next_req).to eql request
              expect(next_res).to match(Response.new('return val'))
            end
            router.call(message)
          end
        end

        context 'when multiple routes are defined' do
          let(:wildcard_handler) { double('wildcard handler', call: 'wildcard') }
          let(:exact_handler) { double('exact handler', call: 'exact') }

          let(:route_handlers) do
            Hash[
              Route.new('a.b.*'), wildcard_handler,
              Route.new('a.b.c'), exact_handler
            ]
          end

          let(:routing_key) { 'a.b.c' }

          it 'raises a RouteConflictError' do
            expect { router.call(message) }.to raise_error(RouteConflictError)
          end
        end

        context 'when route is not defined' do
          let(:routing_key) { 'some.unknown.route' }
          let(:route_handlers) { Hash[] }

          it 'raises an error' do
            expect { router.call(message) }.to raise_error(UndefinedRouteError)
          end
        end
      end

      describe 'parsing route params' do
        let(:payload) { 'payload' }

        let(:route_definition) { '*:domain.*:resource.*:action' }
        let(:routing_key) { 'company.user.add' }
        let(:handler) { double('handler') }
        let(:route) { Route.new(route_definition) }
        let(:route_handlers) { Hash[route, handler] }

        before { allow(app).to receive(:call) }

        it 'calls the handler' do
          route_params = {
            'domain' => 'company',
            'resource' => 'user',
            'action' => 'add'
          }

          expect(handler).to receive(:call) do |_env, req, _res|
            expect(req.route_params).to match(route_params)
          end

          router.call(message)
        end

        context 'given a group wildcard at the beginning of a route' do
          let(:route_definition) { '#.*:resource.*:action' }
          let(:routing_key) { 'user.add' }

          it 'routes correctly' do
            expect(handler).to receive(:call)

            router.call(message)
          end
        end
      end
    end
  end
end
