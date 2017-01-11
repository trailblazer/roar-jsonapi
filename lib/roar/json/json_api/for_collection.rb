module Roar
  module JSON
    module JSONAPI
      # @api private
      module ForCollection
        def collection_representer!(_options)
          singular = self # e.g. Song::Representer

          nested_builder.(_base: default_nested_class, _features: [Roar::JSON, Roar::Hypermedia, JSONAPI::Defaults, JSONAPI::Meta], _block: proc do
            collection :to_a, as: :data, decorator: singular, wrap: false

            # rubocop:disable Metrics/MethodLength
            # rubocop:disable Lint/NestedMethodDefinition
            def to_hash(options = {})
              document = super(to_a: options, user_options: options[:user_options]) # [{data: {..}, data: {..}}]

              links = Renderer::Links.new.(document, options)
              meta  = render_meta(options)
              included = []
              document['data'].each do |single|
                included += single.delete('included') || []
              end

              HashUtils.store_if_any(document, 'included',
                                     Fragment::Included.(included, options))
              HashUtils.store_if_any(document, 'links',    links)
              HashUtils.store_if_any(document, 'meta',     meta)

              document
            end
            # rubocop:enable Lint/NestedMethodDefinition
            # rubocop:enable Metrics/MethodLength
          end)
        end
      end
    end
  end
end
