# frozen_string_literal: true

require 'bundler/setup'
require 'cotton'

app = Cotton::App.new.define do

  queue 'hello_world_queue', exclusive: true do
    handle 'say.hello' do
      puts 'Hello world!'
    end
  end
end

app.start
