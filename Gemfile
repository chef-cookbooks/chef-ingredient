source 'https://rubygems.org'

group :rake do
  gem 'rake'
  gem 'tomlrb'
end

group :lint do
  gem 'foodcritic', '~> 6.0'
  gem 'rubocop', '~> 0.38'
  gem 'rainbow', '< 2.0'
end

group :unit do
  gem 'mixlib-versioning'
  gem 'mixlib-install', '~> 1.1'
  gem 'chef-sugar'
  gem 'chefspec'
  gem 'chef-dk'
end

group :development do
  gem 'ruby_gntp'
  gem 'growl'
  gem 'rb-fsevent'
  gem 'guard', '~> 2.4'
  gem 'guard-kitchen'
  gem 'guard-foodcritic'
  gem 'guard-rspec'
  gem 'guard-rubocop'

  # listen gem which is required by guard requires ruby 2.2 in versions 3.1.X
  # Chef DK ships with ruby 2.1 and we are using it in our testing so we
  # need to pin listen gem to 3.0.X until we update Chef DK with ruby 2.2
  gem 'listen', '~> 3.0.0'
end

# Run kitchen using Chef DK bundled set of gems.
