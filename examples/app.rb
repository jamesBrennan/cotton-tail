#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'cotton_tail'

app = CottonTail::App.new

app.routes.draw do
  # Create the queue 'hello_world_queue' if it does not exists
  queue 'hello_world_queue', exclusive: true do
    # Create a binding from the default topic exchange ('amq.topic') to
    # the queue 'hello_world_queue'. When a message is received with the
    # routing key 'say.hello' the block is executed.
    handle 'say.hello' do
      puts 'Hello world!'
    end

    handle 'say.goodbye' do
      puts 'Goodbye cruel world!'
    end

    handle 'inspect.message' do |env, request, response|
      puts env: env
      puts request: request
      puts response: response
    end
  end

  queue 'require_ack_queue', exclusive: true, manual_ack: true do
    handle 'get.acked' do |_env, request, _response|
      puts "acking with #{request.delivery_tag}"
      request.channel.ack(request.delivery_tag)
    end

    handle 'get.nacked' do |_env, request, _response|
      puts "nacking with #{request.delivery_tag}"
      request.channel.nack(request.delivery_tag)
    end
  end
end

app.start
