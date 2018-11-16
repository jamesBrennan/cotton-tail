# frozen_string_literal: true

require 'middleware'

module CottonTail
  # Configuration options
  class Configuration
    attr_reader :connection_args

    def initialize
      @connection_args = nil
      @middleware = Middleware::DEFAULT_STACK
    end

    # Sets the RabbitMQ connection params. Arguments are eventually passed
    # to Bunny.new. Any valid params for Bunny.new are accepted.
    #
    # @see http://rubybunny.info/articles/connecting.html
    def connection_args=(*args, **kwargs)
      url, = args
      @connection_args = url ? Bunny::Session.parse_uri(url) : kwargs
    end

    # Modify or retrieve the application middleware stack.
    #
    # @see https://github.com/Ibsciss/ruby-middleware
    def middleware
      return @middleware unless block_given?

      @middleware = ::Middleware::Builder.new do |b|
        b.use @middleware
        yield b
      end
    end
  end
end
