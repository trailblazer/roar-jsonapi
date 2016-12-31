require 'roar/json'
require 'roar/decorator'
require 'set'

require 'roar/json/json_api/declarative'
require 'roar/json/json_api/for_collection'
require 'roar/json/json_api/document'

module Roar
  module JSON
    module JSONAPI
      def self.included(base)
        base.class_eval do
          include Roar::JSON
          include Roar::Hypermedia
          extend JSONAPI::Declarative
          extend JSONAPI::ForCollection
          include JSONAPI::Document

          nested :relationships do
          end

          nested :included do
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
        Included = ->(document, included, options) do
          return unless included && included.any?
          return if options[:included] == false

          type_and_id_seen = Set.new

          included = included.select { |object|
            type_and_id_seen.add? [object[:type], object[:id]]
          }

          document[:included] = included
        end

        Links = ->(document, links, _options) do
          document[:links] = links if links.any?
        end

        Meta = ->(document, meta, _options) do
          document[:meta] = meta if meta.any?
        end
      end
    end
  end
end
