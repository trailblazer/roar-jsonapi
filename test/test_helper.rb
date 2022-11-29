require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

require 'roar/representer'
require 'roar/json'
require 'roar/json/json_api'

require 'representable/debug'
require 'pp'

require_relative 'jsonapi/representer'

require 'json_spec/configuration'
require 'json_spec/helpers'
require 'json_spec/exclusion'

if system('colordiff', __FILE__, __FILE__)
  MiniTest::Assertions.diff = 'colordiff -u'
end

module JsonSpec
  extend Configuration

  self.excluded_keys = []
end

module MiniTest
  module Assertions
    def assert_equal_json(actual, expected)
      assert_equal scrub(actual), scrub(expected)
    end

    def scrub(json, path = nil)
      JsonSpec::Helpers.generate_normalized_json(
        JsonSpec::Exclusion.exclude_keys(
          JsonSpec::Helpers.parse_json(json, path)
        )
      ).chomp + "\n"
    end
  end
end

module Minitest
  module Expectations
    infect_an_assertion :assert_equal_json, :must_equal_json
  end
end
