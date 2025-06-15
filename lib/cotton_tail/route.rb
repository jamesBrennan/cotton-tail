# frozen_string_literal: true

require 'delegate'

module CottonTail
  # Route pattern matcher
  class Route < SimpleDelegator
    ##
    # Initializes a new route matcher with the given pattern.
    #
    # @param pattern [String] The dot-separated route pattern to match against routing keys.
    def initialize(pattern)
      @pattern = pattern
      super(build_regex)
    end

    ##
    # Extracts named parameters from a routing key if it matches the route pattern.
    #
    # @param routing_key [String] The routing key to match against the route pattern.
    # @return [Hash{String => String}] A hash of named parameters extracted from the routing key,
    #         or an empty hash if there is no match.
    def extract_params(routing_key)
      return {} unless match? routing_key

      match(routing_key).named_captures
    end

    def binding
      segments.map(&:binding).join('.')
    end

    private

    def explode
      @pattern.split('.').map(&RouteSegment.method(:new))
    end

    def collapse
      segments.zip(separators).join
    end

    def segments
      @segments ||= explode
    end

    def separators
      separators = segments.each_with_index.map do |segment, idx|
        [Regexp.escape('.')].tap do |sep|
          sep << '?' if segment.hash? && idx.zero?
        end
      end
      separators.map(&:join)[0..-2]
    end

    def build_regex
      Regexp.new "^#{collapse}$"
    end
  end
end
