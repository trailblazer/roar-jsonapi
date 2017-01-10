module Roar
  module JSON
    module JSONAPI
      module Meta
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
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
          meta.merge!(options['meta']) if options['meta']
          meta
        end
      end
    end
  end
end
