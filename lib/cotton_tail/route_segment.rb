# frozen_string_literal: true

module CottonTail
  # RouteSegment implements the pattern matching for route segments
  class RouteSegment < SimpleDelegator
    def initialize(value)
      super Regexp.new definition(value)
    end

    private

    TRANSFORM = ->(val, func) { func.call(val) }

    def definition(value)
      transformers.reduce(value, &TRANSFORM)
    end

    # Converts named route segment to Regexp named capture group
    #   "#:foo" -> "(?<foo>.+)"
    def sub_named_group_wildcard(pattern)
      pattern.gsub(/#:(\w+)/, '(?<\1>.+)')
    end

    # Converts named route segment to Regexp named capture group
    #   "*:foo" -> "(?<foo>[^.]+)"
    def sub_named_single_wildcard(pattern)
      pattern.gsub(/\*:(\w+)/, '(?<\1>[^.]+)')
    end

    def sub_single_wildcard(pattern)
      pattern.gsub('*', '([^.]+)')
    end

    def sub_multi_wildcard(pattern)
      pattern.gsub(/\.?#\.?/, '([^.]{0,}\.?)+')
    end

    def transformers
      [
        method(:sub_named_group_wildcard),
        method(:sub_named_single_wildcard),
        method(:sub_single_wildcard),
        method(:sub_multi_wildcard)
      ]
    end
  end
end
