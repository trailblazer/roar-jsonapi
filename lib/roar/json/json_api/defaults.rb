module Roar
  module JSON
    module JSONAPI
      # Defines defaults for JSON API Representers.
      #
      # @api public
      module Defaults
        # Hook called when module is included
        #
        # @param [Class,Module] base
        #   the module or class including Defaults
        #
        # @return [undefined]
        #
        # @api private
        # @see http://www.ruby-doc.org/core/Module.html#method-i-included
        def self.included(base)
          base.defaults do |name, _|
            { as: JSONAPI::MemberName.(name) }
          end
        end
      end
    end
  end
end
