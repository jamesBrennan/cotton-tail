#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'cotton_tail'

app = CottonTail::App.new

upcase = lambda { |(env, req, res)|
  [env, req, CottonTail::Response.new(res.body.upcase)]
}

print = lambda { |(env, req, res)|
  puts res.body
  [env, req, res]
}

app.config.middleware do |d|
  # This is added to the end of the middleware stack
  # 'message' is the return value of the handlers defined below
  d.use upcase
  d.use print
end

app.routes.draw do
  queue 'hello_world_queue', exclusive: true do
    handle 'say.hello' do
      'Hello world!'
    end

    handle 'say.goodbye' do
      'Goodbye cruel world!'
    end
  end
end

app.start
