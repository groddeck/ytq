source "https://rubygems.org"

major, minor, release = RUBY_VERSION.split('.').map(&:to_i)
if major < 1 ||
   (major == 1 && minor < 9) ||
   (major == 1 && minor == 9 && release < 3)
  raise 'Ruby must be >= 1.9.3'
end

gem 'sinatra'
gem 'sinatra-contrib'
gem 'redis'
gem 'resque'

group :development do
  gem 'foreman'
end

group :test do
  gem 'rspec'
end
gem 'rake'
gem 'excon'
gem 'google-api-client'
