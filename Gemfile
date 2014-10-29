source "https://rubygems.org"

# Declare your gem's dependencies in skydrive.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'
gem 'thin'

group :development do
  gem 'guard-embertools'
  gem 'uglifier'
  gem 'ember-source'
  gem 'guard-rspec'
end

group :test do
  gem 'rspec-rails'
  gem 'webmock'
end

group :development, :test do
  gem 'rack-cors'
  gem 'pry'
end
