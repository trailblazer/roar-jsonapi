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
          return super(&block) unless options[:toplevel]
          for_collection.meta(&block)
        end

        def relationship(options = {}, &block); end

        def has_one(name, options = {}, &block)
          has_relationship(name, options.merge(collection: false), &block)
        end

        def has_many(name, options = {}, &block)
          has_relationship(name, options.merge(collection: true), &block)
        end

        private

        def has_relationship(name, options = {}, &block)
          # every nested representer is a full-blown JSONAPI representer.
          nested(:included, inherit: true) do
            property(name, collection: options[:collection]) {
              include Roar::JSON::JSONAPI

              instance_exec(&block)

              def from_document(hash)
                hash
              end
            }
          end

          resource_identifier_representer = Class.new(Roar::Decorator)
          resource_identifier_representer.class_eval do
            include Roar::JSON
            include Roar::Hypermedia
            include JSONAPI::Meta
            extend JSONAPI::Declarative

            def self.relationship_block
              @relationship_block ||= -> {}
            end

            def self.relationship(&block)
              @relationship_block = block
            end

            instance_exec(&block)

            def to_hash(_options)
              hash = { 'type' => self.class.type }.merge(super(include: [:id, :meta]))
              hash['id'] = hash['id'].to_s
              hash
            end
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
                                           decorator:    resource_identifier_representer)

              instance_exec(&resource_identifier_representer.relationship_block)

              def to_hash(*)
                hash  = super
                links = Renderer::Links.new.(hash, {})
                meta  = render_meta({})

                Fragment::Links.(hash, links, {})
                Fragment::Meta.(hash, meta, {})

                hash
              end
            end
          end
        end
      end
    end
  end
end
