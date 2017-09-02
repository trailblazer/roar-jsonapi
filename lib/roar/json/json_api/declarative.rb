module Roar
  module JSON
    module JSONAPI
      # Declarative API for JSON API Representers.
      #
      # @since 0.1.0
      module Declarative
        # Defjne a type for this resource.
        #
        # @example
        #   type :articles
        #
        # @param [Symbol, String] name type name of this resource
        # @return [String] type name of this resource
        #
        # @see http://jsonapi.org/format/#document-resource-object-identification
        # @api public
        def type(name = nil)
          return @type unless name # original name.

          heritage.record(:type, name)
          @type = name.to_s
        end

        # Define attributes for this resource.
        #
        # @example
        #   attributes do
        #     property :name
        #   end
        #
        # @param [#call] block
        #
        # @see http://jsonapi.org/format/#document-resource-object-attributes
        # @api public
        def attributes(&block)
          nested(:attributes, inherit: true, &block)
        end

        # Define a link.
        #
        # @example Link for a resource
        #   link(:self) { "http://authors/#{represented.id}" }
        # @example Top-level link
        #   link(:self, toplevel: true) { "http://authors/#{represented.id}" }
        # @example Link with options
        #   link(:self) do |opts|
        #     "http://articles?locale=#{opts[:user_options][:locale]}"
        #   end
        #
        #   representer.to_json(user_options: { locale: 'de' })
        #
        # @param [Symbol, String] name name of the link.
        # @option options [Boolean] :toplevel place link at top-level of document.
        #
        # @yieldparam opts [Hash] Options passed to render method
        #
        # @see Roar::Hypermedia::ClassMethods#link
        # @see http://jsonapi.org/format/#document-links
        # @api public
        def link(name, options = {}, &block)
          return super(name, &block) unless options[:toplevel]
          for_collection.link(name, &block)
        end

        # Define meta information.
        #
        # @example Meta information for a resource
        #   meta do
        #     collection :reviewers
        #   end
        # @example Top-level meta information
        #   meta toplevel: true do
        #     property :copyright
        #   end
        #
        # @param (see Meta::ClassMethods#meta)
        # @option options [Boolean] :toplevel place meta information at top-level of document.
        #
        # @see Meta::ClassMethods#meta
        # @see http://jsonapi.org/format/#document-meta
        # @api public
        def meta(options = {}, &block)
          return super(&block) unless options[:toplevel]
          for_collection.meta(&block)
        end

        # Define links and meta information for a given relationship.
        #
        # @example
        #   has_one :author, extend: AuthorDecorator do
        #     relationship do
        #       link(:self)     { "/articles/#{represented.id}/relationships/author" }
        #       link(:related)  { "/articles/#{represented.id}/author" }
        #     end
        #   end
        #
        # @param [#call] block
        #
        # @api public
        def relationship(&block)
          return (@relationship ||= -> {}) unless block

          heritage.record(:relationship, &block)
          @relationship = block
        end

        #  Define a to-one relationship for this resource.
        #
        # @param [String] name name of the relationship
        # @option options [Class,Module,Proc] :extend	Representer to use for parsing or rendering
        # @option options [Proc] :prepare	Decorate the represented object
        # @option options [Class,Proc] :class Class to instantiate when parsing nested fragment
        # @option options [Proc] :instance Instantiate object directly when parsing nested fragment
        # @param [#call] block Stuff
        #
        # @see http://trailblazer.to/gems/representable/3.0/function-api.html#options
        # @api public
        def has_one(name, options = {}, &block)
          has_relationship(name, options.merge(collection: false), &block)
        end

        # Define a to-many relationship for this resource.
        #
        # @param (see #has_one)
        # @option options (see #has_one)
        #
        # @api public
        def has_many(name, options = {}, &block)
          has_relationship(name, options.merge(collection: true), &block)
        end

        private

        def has_relationship(name, options = {}, &block)
          resource_decorator = options.delete(:decorator) ||
                               options.delete(:extend)    ||
                               Class.new(Roar::Decorator).tap { |decorator|
                                 decorator.send(:include, JSONAPI::Resource.new(
                                                            name,
                                                            id_key: options.fetch(:id_key, :id)
                                 ))
                               }
          resource_decorator.instance_exec(&block) if block

          resource_identifier_representer = Class.new(resource_decorator)
          resource_identifier_representer.class_eval do
            def to_hash(_options = {})
              super(fields: { self.class.type.to_sym => [] }, include: [], wrap: false)
            end
          end

          nested(:included, inherit: true) do
            property(name, collection: options[:collection],
                           decorator:  resource_decorator,
                           wrap:       false)
          end

          nested(:relationships, inherit: true) do
            nested(:"#{name}_relationship", as: options[:as] || MemberName.(name)) do
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

              # rubocop:disable Lint/NestedMethodDefinition
              def to_hash(*)
                hash  = super
                links = Renderer::Links.new.(hash, {})
                meta  = render_meta({})

                HashUtils.store_if_any(hash, 'links', links)
                HashUtils.store_if_any(hash, 'meta',  meta)

                hash
              end
              # rubocop:enable Lint/NestedMethodDefinition
            end
          end
        end
      end
    end
  end
end
