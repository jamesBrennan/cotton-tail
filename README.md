# CottonTail

[![CircleCI](https://img.shields.io/circleci/project/github/jamesBrennan/cotton-tail.svg?style=svg)](https://circleci.com/gh/jamesBrennan/cotton-tail)
[![Depfu](https://badges.depfu.com/badges/4a33988ba774e985f135172f5f17d86f/overview.svg)](https://depfu.com/github/jamesBrennan/cotton-tail?project_id=6465)
[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/jamesBrennan/cotton-tail)

CottonTail lets you declare RabbitMQ queues and routing-key patterns as elegantly as you declare HTTP routes in a web framework, processes messages through a familiar middleware pipeline, and keeps all the AMQP/Bunny plumbing out of sight.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cotton-tail'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cotton-tail

## Usage

### Quick Start (Hello World)

```ruby
require 'bundler/setup'
require 'cotton_tail'

app = CottonTail::App.new

app.routes.draw do
  # Create the queue 'hello_world' if it does not exists
  queue 'hello_world', exclusive: true do
    # Create a binding from the default topic exchange ('amq.topic') to
    # the queue 'hello_world'. When a message is received with the
    # routing key 'say.hello' the block is executed.
    handle 'say.hello' do
      puts 'Hello world!'
    end
  end
end

app.start
```

To run the example locally you need to have a rabbitmq instance running. The
included `docker-compose` file can be used to start up a local instance of
rabbitmq.

`docker-compose up`

Once the rabbitmq service has completed startup (takes a few seconds) you can
start the example app.

`bundle exec examples/app.rb`

You should see

`Waiting for messages ...`

We've included bash scripts to publish messages for the example app. Execute them
in another terminal window to see output in the app window.

`examples/messages/say.hello`, `examples/messages/say.goodbye`, etc...

## Development

After checking out the repo, install docker. Then, run `docker-compose` up to 
spin up a local instance of rabbitmq. Run `rake spec:all` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you 
to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jamesBrennan/cotton-tail.
