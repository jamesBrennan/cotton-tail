#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'cotton'

app = Cotton::App.new.define do
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

    handle 'inspect.message' do |delivery_info, properties, message|
      puts delivery_info: delivery_info
      puts properties: properties
      puts message: message
    end
  end

  queue 'require_ack_queue', exclusive: true, manual_ack: true do
    handle 'get.acked' do |delivery_info, _props, _msg, opts|
      conn = opts[:conn]
      delivery_tag = delivery_info[:delivery_tag]
      puts "acking with #{delivery_tag}"
      conn.ack(delivery_tag)
    end

    handle 'get.nacked' do |delivery_info, _props, _msg, opts|
      conn = opts[:conn]
      delivery_tag = delivery_info[:delivery_tag]
      puts "nacking with #{delivery_tag}"
      conn.nack(delivery_tag)
    end
  end
end

app.start
