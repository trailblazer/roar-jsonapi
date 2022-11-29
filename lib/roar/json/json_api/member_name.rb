# encoding=utf-8

module Roar
  module JSON
    module JSONAPI
      # Member Name formatting according to the JSON API specification.
      #
      # @see http://jsonapi.org/format/#document-member-names
      # @since 0.1.0
      class MemberName
        # @api private
        LENIENT_FILTER_REGEXP = /([^[:alnum:][-_ ]]+)/
        # @api private
        STRICT_FILTER_REGEXP  = /([^[0-9a-z][-_]]+)/

        # @see #call
        def self.call(name, options = {})
          new.(name, options)
        end

        # Format a member name
        #
        # @param [String, Symbol] name
        #   member name.
        # @option options [Boolean] :strict
        #   whether strict mode is enabled.
        #
        #   Strict mode applies additional JSON Specification *RECOMMENDATIONS*,
        #   permitting only non-reserved, URL safe characters specified in RFC 3986.
        #   The member name will be lower-cased and underscores will be
        #   transformed to hyphens.
        #
        #   Non-strict mode permits:
        #   * non-ASCII alphanumeric Unicode characters.
        #   * spaces, underscores and hyphens, except as the first or last character.
        #
        # @return [String] formatted member name.
        #
        # @api public
        def call(name, options = {})
          name    = name.to_s
          strict  = options.fetch(:strict, true)
          name = if strict
                   name = name.downcase
                   name.gsub(STRICT_FILTER_REGEXP, ''.freeze)
                 else
                   name.gsub(LENIENT_FILTER_REGEXP, ''.freeze)
                 end
          name = name.gsub(/\A([-_ ])/, '')
          name = name.gsub(/([-_ ])\z/, '')
          name = name.tr('_', '-') if strict
          name
        end
      end
    end
  end
end
