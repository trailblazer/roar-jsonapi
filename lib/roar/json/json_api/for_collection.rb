module Roar
  module JSON
    module JSONAPI
      module ForCollection
        def collection_representer!(_options) # FIXME: cache.
          singular = self # e.g. Song::Representer

          # this basically does Module.new { include Hash::Collection .. }
          nested_builder.(_base: default_nested_class, _features: [Roar::JSON, Roar::Hypermedia, JSONAPI::Meta], _block: proc do
            collection :to_a, decorator: singular # render/parse every item using the singular representer.

            # toplevel links are defined here, as in
            # link(:self) { .. }

            def to_hash(options = {})
              hash = super(to_a: options, user_options: options[:user_options]) # [{data: {..}, data: {..}}]
              collection = hash['to_a']
              meta       = render_meta(options)

              document = { 'data' => [] }
              included = []
              collection.each do |single|
                document['data'] << single['data']
                included += single.delete('included') || []
              end

              Fragment::Links.(document, Renderer::Links.new.(hash, {}), options)
              Fragment::Included.(document, included, options)
              Fragment::Meta.(document, meta, options)

              document
            end
          end)
        end
      end
    end
  end
end
