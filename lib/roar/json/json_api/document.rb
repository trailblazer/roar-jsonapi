module Roar
  module JSON
    module JSONAPI
      # {:include=>[:id, :title, :author, :included],
      #  :included=>{:include=>[:author], :author=>{:include=>[:email, :id]}}}
      module Options
        Include = ->(options) do
          return options if options[:_json_api_parsed] || !(options[:include] || options[:fields])

          _include  = options[:include]   || []
          fields    = options[:fields]    || {}
          mappings  = options[:mappings]  || {}

          internal_options = {}
          internal_options[:include]  = [:id, :included]
          internal_options[:included] = { include: _include - [:_self] }
          fields.each do |type, value|
            if mappings.key(type) == :_self
              internal_options[:include] << :attributes << :relationships
              internal_options[:attributes]     = { include: value }
              internal_options[:relationships]  = { include: value }
            else
              relationship_name = mappings.key(type) || type
              internal_options[:included][relationship_name] = {
                include:          [:id, :included, :attributes, :relationships],
                attributes:       { include: value },
                relationships:    { include: value },
                _json_api_parsed: true # flag to halt recursive parsing
              }
            end
          end

          options.select { |key, _| ![:fields, :include, :mappings].include?(key) }
                 .merge(internal_options)
        end
      end

      module Document
        # rubocop:disable Metrics/MethodLength
        def to_hash(options = {})
          document  = super(Options::Include.(options))
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
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
