# encoding=utf-8

module Roar
  module JSON
    module JSONAPI
      class MemberName
        LENIENT_FILTER_REGEXP = /([^[:alnum:][-_ ]]+)/
        STRICT_FILTER_REGEXP  = /([^[0-9a-z][-_]]+)/

        def self.call(name, options = {})
          new.(name, options)
        end

        def call(name, options = {})
          name = name.to_s
          if options[:strict]
            name.downcase!
            name.gsub!(STRICT_FILTER_REGEXP, ''.freeze)
          else
            name.gsub!(LENIENT_FILTER_REGEXP, ''.freeze)
          end
          name.gsub!(/\A([-_ ])/, '')
          name.gsub!(/([-_ ])\z/, '')
          name.tr!('_', '-') if options[:strict]
          name
        end
      end
    end
  end
end
