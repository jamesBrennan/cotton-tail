# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :spec do
  desc 'Run integration specs'
  task :integration do
    puts `docker-compose exec cotton-tail bundle exec rspec integration`
  end

  desc 'Run all specs'
  task all: %w[spec spec:integration]
end
