require 'roar/json'
require 'roar/decorator'
require 'set'

require 'roar/json/json_api/meta'
require 'roar/json/json_api/declarative'
require 'roar/json/json_api/for_collection'
require 'roar/json/json_api/options'
require 'roar/json/json_api/document'

module Roar
  module JSON
    module JSONAPI
      def self.included(base)
        base.class_eval do
          feature Roar::JSON
          feature Roar::Hypermedia
          feature JSONAPI::Meta
          extend JSONAPI::Declarative
          extend JSONAPI::ForCollection
          include JSONAPI::Document
          self.representation_wrap = :data

          property :id, render_filter: ->(input, _options) { input.to_s }

          nested :relationships do
          end

          nested :included do
            def to_hash(*)
              super.flat_map { |_, resource| resource }
            end
          end
        end
      end

      module Renderer
        class Links
          def call(res, _options)
            tuples = (res.delete('links') || []).collect { |link| [link['rel'], link['href']] }
            # tuples.to_h
            ::Hash[tuples] # TODO: tuples.to_h when dropping < 2.1.
          end
        end
      end

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

    module HashUtils
      def store_if_any(hash, key, value)
        hash[key] = value if value && value.any?
      end
      module_function :store_if_any
    end
  end
end
