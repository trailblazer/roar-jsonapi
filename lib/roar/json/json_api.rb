require 'roar/json'
require 'roar/decorator'
require 'set'

require 'roar/json/json_api/member_name'

require 'roar/json/json_api/defaults'
require 'roar/json/json_api/meta'
require 'roar/json/json_api/declarative'
require 'roar/json/json_api/options'
require 'roar/json/json_api/document'

require 'roar/json/json_api/single_resource'
require 'roar/json/json_api/resource_collection'
require 'roar/json/json_api/for_collection'

module Roar
  module JSON
    module JSONAPI
      # Include to define a JSON API Resource and make API methods available to
      # your `Roar::Decorator`.
      #
      # @api public
      class Resource < Module
        # @param [Symbol, String] type type name of this resource.
        # @option options [Symbol] :id_key custom ID key for this resource.
        def initialize(type, options = {})
          @type   = type
          @id_key = options.fetch(:id_key, :id)
        end

        private

        # Hook called when module is included
        #
        # @param [Class,Module] base
        #   the module or class including JSONAPI
        #
        # @return [undefined]
        #
        # @api private
        # @see http://www.ruby-doc.org/core/Module.html#method-i-included
        def included(base)
          base.send(:include, JSONAPI::Mixin)
          base.type(@type)
          base.property(@id_key, as: :id, render_filter: ->(input, _opts) {
                                                           input.to_s
                                                         })
        end
      end

      # Include to define a JSON API Resource and make API methods available to
      # your `Roar::Decorator`.
      #
      # @example Basic Usage
      #   class SongsRepresenter < Roar::Decorator
      #     include Roar::JSON::JSONAPI.resource :songs
      #   end
      #
      # @example Custom ID key
      #   class SongsRepresenter < Roar::Decorator
      #     include Roar::JSON::JSONAPI.resource :songs, id_key: :song_id
      #   end
      #
      # @param (see Resource.initialize)
      # @option options (see Resource.initialize)
      #
      # @see Mixin
      # @api public
      def self.resource(type, options = {})
        Resource.new(type, options)
      end

      # Include to make API methods available to your `Roar::Decorator`.
      #
      # Unlike {Resource}, you must define a `type` (by calling
      # {Declarative#type}) and `id` property separately.
      #
      # @example Basic Usage
      #   class SongsRepresenter < Roar::Decorator
      #     include Roar::JSON::JSONAPI::Mixin
      #
      #     type :songs
      #     property :id
      #   end
      #
      # @see Resource
      # @api semi-public
      module Mixin
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
          base.class_eval do
            feature Roar::JSON
            feature Roar::Hypermedia
            feature JSONAPI::Defaults, JSONAPI::Meta
            extend JSONAPI::Declarative
            extend JSONAPI::ForCollection
            include JSONAPI::Document
            include JSONAPI::SingleResource
            self.representation_wrap = :data

            nested :relationships do
            end

            nested :included do
              def to_hash(*)
                super.flat_map { |_, resource| resource }
              end
            end
          end
        end
      end

      # @api private
      module Renderer
        class Links
          def call(res, _options)
            tuples = (res.delete('links') || []).collect { |link|
              [JSONAPI::MemberName.(link['rel']), link['href']]
            }

            ::Hash[tuples] # NOTE: change to tuples.to_h when dropping < 2.1.
          end
        end
      end

      # @api private
      module Fragment
        Included = ->(included, options) do
          return unless included && included.any?
          return if options[:included] == false

          type_and_id_seen = Set.new

          included = included.select { |object|
            type_and_id_seen.add? [object['type'], object['id']]
          }

          included
        end
      end
    end

    # @api private
    module HashUtils
      def store_if_any(hash, key, value)
        hash[key] = value if value && value.any?
      end
      module_function :store_if_any
    end
  end
end
