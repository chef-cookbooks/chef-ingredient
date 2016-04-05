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
  gem 'mixlib-install', '~> 1.0'
  gem 'chef-sugar'
  gem 'chefspec', github: 'sersut/chefspec', branch: 'sersut/export-repo-compat'
  gem 'chef-dk'

  # Pin nokogiri to 1.6.7.2 until the new version can install in travis.
  gem 'nokogiri', '= 1.6.7.2'
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
end

# Run kitchen using Chef DK bundled set of gems.
