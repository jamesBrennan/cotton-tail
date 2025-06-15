# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cotton_tail/version'

Gem::Specification.new do |spec|
  spec.name          = 'cotton-tail'
  spec.version       = CottonTail::VERSION
  spec.authors       = ['James Brennan']
  spec.email         = ['brennanmusic@gmail.com']
  spec.homepage      = 'https://github.com/jamesBrennan/cotton-tail'

  spec.summary       = 'A simple multi-threaded amqp server'
  spec.description   = 'Simply and easily add AMQP messaging capabilities to
                          your services'

  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'
  spec.cert_chain  = ['certs/jamesbrennan.pem']
  spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME.end_with? 'gem'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|integration)/})
  end

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bunny', '~> 2.24'
  spec.add_dependency 'ibsciss-middleware', '~> 0.4.3'

  spec.add_development_dependency 'bundler', '~> 2.5'
  spec.add_development_dependency 'rabbitmq_http_api_client', '~> 3.0'
  spec.add_development_dependency 'rake', '~> 13.3'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rspec-benchmark', '~> 0.6'
  spec.add_development_dependency 'rspec-its', '~> 2.0'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop', '~> 1.76'
  spec.add_development_dependency 'rubocop-rake', '~> 0.7.1'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.6'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
