module Roar
  module JSON
    module JSONAPI
      module Document
        # rubocop:disable Metrics/MethodLength
        def to_hash(options = {})
          document  = super(Options::Include.(options, relationship_type_mappings))
          unwrapped = options[:wrap] == false
          resource  = unwrapped ? document : document['data']
          resource['type'] = JSONAPI::MemberName.(self.class.type)

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

        private

        def relationship_type_mappings
          @relationship_type_mappings ||= begin
            mappings = included_definitions.each_with_object({}) do |definition, hash|
              hash[definition.name.to_sym] = definition.representer_module.type.to_sym
            end
            mappings[:_self] = self.class.type.to_sym
            mappings
          end
        end

        def included_definitions
          self.class.definitions['included'].representer_module.definitions
        end
      end
    end
  end
end
