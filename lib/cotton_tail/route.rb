# frozen_string_literal: true

module CottonTail
  # Route value object
  class Route
    attr_reader :pattern

    def initialize(pattern)
      @pattern = pattern
    end

    def match?(routing_key)
      return true if @pattern == routing_key

      regex.match? routing_key
    end

    def to_s
      @pattern
    end

    def wildcard_names
      regex.names
    end

    private

    def regex
      @regex ||= Regexp.new build_regex(@pattern)
    end

    def regex_def(pattern)
      segments(pattern).map(&:to_regex).join('\.')
    end

    def segments(pattern)
      pattern.split('.').map(&RouteSegment.method(:new))
    end

    def build_regex(pattern)
      ['^', regex_def(pattern), '$'].join
    end
  end
end
