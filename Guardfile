# More info at https://github.com/guard/guard#readme

# guard 'foodcritic', :cookbook_paths => '.', :cli => '-t ~FC023 -t ~FC005', :all_on_start => false do
#   watch(/attributes\/.+\.rb$/)
#   watch(/providers\/.+\.rb$/)
#   watch(/recipes\/.+\.rb$/)
#   watch(/resources\/.+\.rb$/)
#   watch('metadata.rb')
# end

guard 'rubocop' do
  watch(%r{attributes\/.+\.rb$})
  watch(%r{providers\/.+\.rb$})
  watch(%r{recipes\/.+\.rb$})
  watch(%r{resources\/.+\.rb$})
  watch('metadata.rb')
end

guard :rspec, cmd: 'chef exec /opt/chefdk/embedded/bin/rspec', all_on_start: false, notification: false do
  watch(%r{^libraries\/(.+)\.rb$})
  watch(%r{^spec\/(.+)_spec\.rb$})
  watch(%r{^(recipes)\/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { 'spec' }
end
