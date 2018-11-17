#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'cotton_tail'

CottonTail.application.routes.draw do
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

    handle 'inspect.message' do |env, routing_key, delivery_info, properties, payload|
      puts env: env
      puts routing_key: routing_key
      puts delivery_info: delivery_info
      puts properties: properties
      puts payload: payload
    end
  end

  queue 'require_ack_queue', exclusive: true, manual_ack: true do
    handle 'get.acked' do |_env, _routing_key, delivery_info, _properties, _message|
      delivery_tag = delivery_info[:delivery_tag]
      puts "acking with #{delivery_tag}"

      ch = delivery_info[:channel]
      ch.ack(delivery_tag)
    end

    handle 'get.nacked' do |_env, _routing_key, delivery_info, _properties, _message|
      delivery_tag = delivery_info[:delivery_tag]
      puts "nacking with #{delivery_tag}"

      ch = delivery_info[:channel]
      ch.nack(delivery_tag)
    end
  end
end

CottonTail.application.start
