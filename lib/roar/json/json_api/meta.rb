module Roar
  module JSON
    module JSONAPI
      # Meta information API for JSON API Representers.
      #
      # @api public
      module Meta
        # Hook called when module is included
        #
        # @param [Class,Module] base
        #   the module or class including JSONAPI
        #
        # @return [undefined]
        #
        # @api private
        # @see http://www.ruby-doc.org/core/Module.html#method-i-included
        def self.included(base)
          base.extend ClassMethods
        end

        # Class level interface
        module ClassMethods
          # Define meta information.
          #
          # @example
          #   meta do
          #     property :copyright
          #     collection :reviewers
          #   end
          #
          # @param [#call] block
          #
          # @see http://jsonapi.org/format/#document-meta
          # @api public
          def meta(&block)
            representable_attrs[:meta_representer] ||= nested_builder.(
              _base:     default_nested_class,
              _features: [Roar::JSON, JSONAPI::Defaults],
              _block:    Proc.new
            )
            representable_attrs[:meta_representer].instance_exec(&block)
          end
        end

        private

        def render_meta(options)
          representer = representable_attrs[:meta_representer]
          meta        = representer ? representer.new(represented).to_hash : {}
          meta.merge!(options[:meta]) if options[:meta]
          meta
        end
      end
    end
  end
end
