# frozen_string_literal: true

module CottonTail
  # Configuration options
  class Configuration
    attr_reader :connection_args

    def initialize
      @connection_args = nil
    end

    def connection_args=(*args, **kwargs)
      url, = args
      @connection_args = url ? Bunny::Session.parse_uri(url) : kwargs
    end
  end
end
