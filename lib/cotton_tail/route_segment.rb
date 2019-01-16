# frozen_string_literal: true

module CottonTail
  # RouteSegment implements the pattern matching for route segments
  class RouteSegment < SimpleDelegator
    def initialize(value)
      @value = value
      super Regexp.new definition(value)
    end

    def star?
      /^#{STAR}|#{NAMED_STAR}$/.match? @value
    end

    def hash?
      /^#{HASH}|#{NAMED_HASH}$/.match? @value
    end

    private

    TRANSFORM = ->(val, func) { func.call(val) }

    def definition(value)
      transformers.reduce(value, &TRANSFORM)
    end

    # Converts named route segment to Regexp named capture group
    #   "#:foo" -> "(?<foo>.+)"
    def sub_named_group_wildcard(pattern)
      pattern.gsub(NAMED_HASH, '(?<\1>.+)')
    end

    # Converts named route segment to Regexp named capture group
    #   "*:foo" -> "(?<foo>[^.]+)"
    def sub_named_single_wildcard(pattern)
      pattern.gsub(NAMED_STAR, '(?<\1>[^.]+)')
    end

    def sub_single_wildcard(pattern)
      pattern.gsub(STAR, '([^.]+)')
    end

    def sub_multi_wildcard(pattern)
      pattern.gsub(HASH, '([^.]{0,}\.?)+')
    end

    def transformers
      [
        method(:sub_named_group_wildcard),
        method(:sub_named_single_wildcard),
        method(:sub_single_wildcard),
        method(:sub_multi_wildcard)
      ]
    end

    STAR = /\*/.freeze
    HASH = /#/.freeze
    NAMED = /:(\w+)/.freeze
    NAMED_STAR = /#{STAR}#{NAMED}/.freeze
    NAMED_HASH = /#{HASH}#{NAMED}/.freeze
  end
end
