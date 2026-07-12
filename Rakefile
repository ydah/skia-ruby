# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:lint)
YARD::Rake::YardocTask.new(:docs)

task default: %i[lint spec]

namespace :skia do
  desc 'Install the SkiaSharp native library into the user data directory'
  task :install_native do
    ruby File.expand_path('exe/skia-install-native', __dir__)
  end
end
