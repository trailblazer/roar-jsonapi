module Roar
  module JSON
    module JSONAPI
      # {:include=>[:id, :title, :author, :included],
      #  :included=>{:include=>[:author], :author=>{:include=>[:email, :id]}}}
      module Options
        Include = ->(options, _decorator) do
          return options unless options[:include]
          included = options[:include] | [:id]
          return options.merge(include: included) unless options[:fields]

          internal_options = {}
          internal_options[:include] = [*included, :included]

          fields = options[:fields] || {}
          internal_options[:included] = { include: fields.keys }
          fields.each do |k, v|
            internal_options[:included][k] = { include: v + [:id] }
          end
          options.merge(internal_options)
        end
      end

      module Document
        def to_hash(options = {})
          document  = super(Options::Include.(options, self))
          unwrapped = options[:wrap] == false
          resource  = unwrapped ? document : document['data']
          resource['type'] = self.class.type

          links = Renderer::Links.new.(resource, options)
          meta  = render_meta(options)

          resource.reject! do |_, v| v && v.empty? end

          unless unwrapped
            included = resource.delete('included')

            HashUtils.store_if_any(document, 'included',
                                   Fragment::Included.(included, options))
          end

          HashUtils.store_if_any(resource, 'links', links)
          HashUtils.store_if_any(document, 'meta',  meta)

          document
        end
      end
    end
  end
end
