# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cotton/version'

Gem::Specification.new do |spec|
  spec.name          = 'cotton'
  spec.version       = Cotton::VERSION
  spec.authors       = ['James Brennan']
  spec.email         = ['james.brennan@educationsuperhighway.org']

  spec.summary       = 'A simple multi-threaded amqp server'
  spec.description   = 'Simply and easily add AMQP messaging capabilities to
                          your services'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|integration)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bunny', '~> 2.12'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rabbitmq_http_api_client', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-benchmark', '~> 0.4'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'rubocop', '~> 0.60'
end
