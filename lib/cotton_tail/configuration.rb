# frozen_string_literal: true

require 'middleware'
require 'amq/settings'

module CottonTail
  # Configuration options
  class Configuration
    attr_reader :connection_args

    def initialize(middleware: nil)
      @connection_args = nil
      @middleware = middleware
      @user_configs = {}
    end

    # Sets the RabbitMQ connection params. Arguments are eventually passed
    # to Bunny.new. Any valid params for Bunny.new are accepted.
    #
    ##
    # Sets the connection arguments for RabbitMQ using the provided parameters.
    #
    # The parameters are processed through AMQ::Settings.configure and stored for later use.
    #
    # @see http://rubybunny.info/articles/connecting.html
    # @param params [Hash, String] Connection parameters or URI for RabbitMQ
    def connection_args=(params)
      @connection_args = AMQ::Settings.configure(params)
    end

    # Modify or retrieve the application middleware stack.
    #
    # @see https://github.com/Ibsciss/ruby-middleware
    def middleware
      return @middleware unless block_given?

      @middleware = ::Middleware::Builder.new do |b|
        b.use @middleware if @middleware
        yield b
      end
    end

    def method_missing(method_id, *arguments, &block)
      if user_config? method_id
        @user_configs[method_id]
      elsif setter?(method_id) && arguments.length == 1
        @user_configs[getter_name(method_id)] = arguments.first
      else
        super
      end
    end

    def respond_to_missing?(method_id, include_private = false)
      user_config?(method_id) || super
    end

    private

    def setter?(method_id)
      method_id.to_s.end_with? '='
    end

    def user_config?(method_id)
      @user_configs.key?(method_id)
    end

    def getter_name(setter)
      setter.to_s.sub('=', '').to_sym
    end
  end
end
