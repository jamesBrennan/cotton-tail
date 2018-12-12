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

    private

    def regex
      @regex ||= Regexp.new build_regex(@pattern)
    end

    def build_regex(pattern)
      [
        '^',
        pattern.gsub('*', '([^.]+)').gsub(/\.?#\.?/, '([^.]{0,}\.?)+'),
        '$'
      ].join
    end
  end
end
