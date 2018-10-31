# frozen_string_literal: true

require 'bundler/setup'
require 'cotton'

app = Cotton::App.new.define do
  queue 'hello_world_queue' do
    handle('say.hello', proc { puts 'Hello world!' })
  end
end

app.start
