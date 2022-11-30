source 'https://rubygems.org'
git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}.git"
end

gemspec

case ENV["GEMS_SOURCE"]
when "local"
  gem "roar", path: "../roar"
when "github"
  gem 'roar', github: 'trailblazer/roar'
end

gem 'minitest-line'
gem 'minitest-reporters', '<= 1.3.0' # Note 1.3.1 is broken see https://github.com/kern/minitest-reporters/issues/267
gem 'pry'

gem 'json_spec', require: false
