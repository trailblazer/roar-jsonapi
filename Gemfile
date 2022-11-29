source 'https://rubygems.org'
git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}.git"
end

gemspec

case ENV['GEMS_SOURCE']
when 'local'
  gem 'roar', path: '../roar'
when 'github'
  gem 'roar', github: 'trailblazer/roar'
end

gem 'minitest-line'
gem 'minitest-reporters', '<= 1.3.0' # Note 1.3.1 is broken see https://github.com/kern/minitest-reporters/issues/267
gem 'pry'

if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.6.0')
  gem 'rubocop', '~> 0.41.0' # RuboCop dropped support for Ruby 1.9 after v0.41
end

gem 'json_spec', require: false
