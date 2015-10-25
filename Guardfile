# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
end

guard 'rspec', :cmd => "bundle exec rspec" , :notification => false do
  watch(%r{^(lib|spec)/.+\.rb$}) { "spec" }
end
