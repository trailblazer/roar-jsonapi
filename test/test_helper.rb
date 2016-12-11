require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

require 'roar/representer'
require 'roar/json'
require 'roar/json/json_api'

require 'representable/debug'
require 'pp'
