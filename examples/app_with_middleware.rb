#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'cotton_tail'

# Simple middleware that logs the given value before and after
class Trace
  def initialize(app, value)
    @app   = app
    @value = value
  end

  def call(env)
    puts "--> #{@value}"
    @app.call(env)
    puts "<-- #{@value}"
  end
end

CottonTail.configure do |config|
  config.middleware do |d|
    d.use Trace, 'A'
    d.use Trace, 'B'
  end
end

app = CottonTail::App.new.define do
  queue 'hello_world_queue', exclusive: true do
    handle 'say.hello' do
      puts 'Hello world!'
    end
  end
end

app.start
