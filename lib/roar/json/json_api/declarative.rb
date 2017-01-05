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

        def attributes(&block)
          nested(:attributes, inherit: true, &block)
        end

        def link(name, options = {}, &block)
          return super(name, &block) unless options[:toplevel]
          for_collection.link(name, &block)
        end

        def meta(options = {}, &block)
          return super(&block) unless options[:toplevel]
          for_collection.meta(&block)
        end

        def relationship(&block)
          return (@relationship ||= -> {}) unless block

          heritage.record(:relationship, &block)
          @relationship = block
        end

        def has_one(name, options = {}, &block)
          has_relationship(name, options.merge(collection: false), &block)
        end

        def has_many(name, options = {}, &block)
          has_relationship(name, options.merge(collection: true), &block)
        end

        private

        def has_relationship(name, options = {}, &block)
          resource_decorator = options.fetch(:decorator) {
            blank_decorator = Class.new(Roar::Decorator)
            blank_decorator.send(:include, Roar::JSON::JSONAPI)
            blank_decorator.instance_exec(&block)
            blank_decorator
          }

          resource_identifier_representer = Class.new(resource_decorator)
          resource_identifier_representer.class_eval do
            def to_hash(_options = {})
              super(include: [:id, :meta], wrap: false)
            end
          end

          nested(:included, inherit: true) do
            property(name, collection: options[:collection],
                           decorator:  resource_decorator,
                           wrap:       false)
          end

          nested(:relationships, inherit: true) do
            nested(:"#{name}_relationship", as: name) do
              include Roar::JSON
              include Roar::Hypermedia
              include JSONAPI::Meta

              property name, options.merge(as:           :data,
                                           getter:       ->(opts) {
                                             object = opts[:binding].send(:exec_context, opts)
                                             value  = object.public_send(opts[:binding].getter)
                                             # do not blow up on nil collections
                                             if options[:collection] && value.nil?
                                               []
                                             else
                                               value
                                             end
                                           },
                                           render_nil:   true,
                                           render_empty: true,
                                           decorator:    resource_identifier_representer,
                                           wrap:         false)

              instance_exec(&resource_identifier_representer.relationship)

              def to_hash(*)
                hash  = super
                links = Renderer::Links.new.(hash, {})
                meta  = render_meta({})

                HashUtils.store_if_any(hash, 'links', links)
                HashUtils.store_if_any(hash, 'meta',  meta)

                hash
              end
            end
          end
        end
      end
    end
  end
end
