begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)

  task default: [:rubocop]
rescue LoadError
  puts 'RuboCop not available'
end
