module Roar
  module JSON
    module JSONAPI
      # New API for JSON-API representers.
      module Declarative
        def type(name = nil)
          return @type unless name # original name.

          heritage.record(:type, name)
          @type = name.to_s
        end

        def link(name, options = {}, &block)
          return super(name, &block) unless options[:toplevel]
          for_collection.link(name, &block)
        end

        def meta(options = {}, &block)
          return for_collection.meta(name, &block) if options[:toplevel]

          representable_attrs[:meta_representer] ||= begin
            meta_representer = Class.new(Roar::Decorator)
            meta_representer.send :include, Roar::JSON
            meta_representer
          end
          representable_attrs[:meta_representer].instance_exec(&block)
        end

        def has_one(name, options = {}, &block)
          has_relationship(name, options.merge(collection: false), &block)
        end

        def has_many(name, options = {}, &block)
          has_relationship(name, options.merge(collection: true), &block)
        end

        private

        def has_relationship(name, options = {}, &block)
          # every nested representer is a full-blown JSONAPI representer.
          dfn        = nil
          collection = options.fetch(:collection)

          nested(:included, inherit: true) do
            dfn = property(name, collection: collection) {
              include Roar::JSON::JSONAPI
              include Roar::JSON
              include Roar::Hypermedia

              instance_exec(&block)

              def from_document(hash)
                hash
              end
            }
          end

          property_representer = Class.new(dfn[:extend].(nil))
          property_representer.class_eval do
            def to_hash(_options)
              super(include: [:type, :id, :links])
            end
          end

          nested(:relationships, inherit: true) do
            property(name, options.merge(decorator: property_representer))
          end
        end
      end
    end
  end
end
