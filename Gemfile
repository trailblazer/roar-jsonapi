source 'https://rubygems.org'
git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}.git"
end

ruby RUBY_VERSION

gemspec

case ENV["GEMS_SOURCE"]
when "local"
  gem "roar", path: "../roar"
when "github"
  gem 'roar', github: 'trailblazer/roar'
end

gem 'minitest-line'
gem 'minitest-reporters'
gem 'pry'

gem 'json_spec', require: false
