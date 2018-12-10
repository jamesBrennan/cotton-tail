#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'cotton_tail'

app = CottonTail::App.new

upcase = lambda { |(env, req, res)|
  res[:body] = res.body.upcase
  [env, req, res]
}

print = lambda { |(env, req, res)|
  puts res.body
  [env, req, res]
}

Interceptor = Class.new do
  def initialize(app)
    @app = app
  end

  def call(msg)
    _env, req, _res = msg
    if req.routing_key == 'intercept.with.middleware'
      puts 'INTERCEPTED!'
      return
    end

    @app.call msg
  end
end

app.config.middleware do |d|
  d.insert_before CottonTail::Middleware::Router, Interceptor
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

    bind 'intercept.with.middleware'
  end
end

app.start
