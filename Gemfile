source 'https://rubygems.org'

group :lint do
  gem 'foodcritic', '~> 4.0'
  gem 'rubocop', '~> 0.18'
  gem 'rainbow', '< 2.0'
  gem 'rake'
end

group :unit do
  # This is required to have policyfile support for ChefSpec
  gem 'chefspec',
    git: 'https://github.com/sethvargo/chefspec',
    ref: 'cd57e28fdbd59fc26962c0dd3b1809b8841312f3'

  gem 'chef-dk', '~> 0.7.0'
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
  gem 'mixlib-versioning'
  gem 'mixlib-install', github: 'chef/mixlib-install'
end

# Run kitchen using Chef DK bundled set of gems.
