module Roar
  module JSON
    module JSONAPI
      module Meta
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def meta(&block)
            representable_attrs[:meta_representer] ||= begin
              meta_representer = Class.new(Roar::Decorator)
              meta_representer.send :include, Roar::JSON
              meta_representer
            end
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
