module Roar
  module JSON
    module JSONAPI
      # @api private
      module ForCollection
        def collection_representer!(_options)
          singular = self # e.g. Song::Representer

          nested_builder.(_base: default_nested_class, _features: [Roar::JSON, Roar::Hypermedia, JSONAPI::Defaults, JSONAPI::Meta], _block: proc do
            collection :to_a, as: :data, decorator: singular, wrap: false

            include Document
            include ResourceCollection
          end)
        end
      end
    end
  end
end
