# Cotton

Cotton provides a simple DSL for consuming messages from a RabbitMQ server

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cotton'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cotton

## Usage

### Quick Start

You can look at the file `examples/app.rb` to see an example of what a Cotton
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

Bug reports and pull requests are welcome on GitHub at https://github.com/jamesBrennan/cotton.
