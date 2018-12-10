# CottonTail

[![CircleCI](https://img.shields.io/circleci/project/github/jamesBrennan/cotton-tail.svg?style=svg)](https://circleci.com/gh/jamesBrennan/cotton-tail)
[![Depfu](https://badges.depfu.com/badges/4a33988ba774e985f135172f5f17d86f/overview.svg)](https://depfu.com/github/jamesBrennan/cotton-tail?project_id=6465)
[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/jamesBrennan/cotton-tail)

CottonTail provides a simple DSL for consuming messages from a RabbitMQ server.

This gem is in early development. The API will be unstable until the 1.0.0
release.

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

### Quick Start

You can look at the file `examples/app.rb` to see an example of what a CottonTail
App definition looks like.

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
