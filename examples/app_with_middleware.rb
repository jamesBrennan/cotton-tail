#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'cotton_tail'

CottonTail.configure.middleware do |d|
  # This is added to the end of the middleware stack
  # 'message' is the return value of the handlers defined below
  d.use ->(message) { puts message.upcase }
end

CottonTail.application.routes.draw do
  queue 'hello_world_queue', exclusive: true do
    handle 'say.hello' do
      'Hello world!'
    end

    handle 'say.goodbye' do
      'Goodbye cruel world!'
    end
  end
end

CottonTail.application.start
