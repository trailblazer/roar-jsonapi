module Roar
  module JSON
    module JSONAPI
      # Instance method API for JSON API Documents representing a single Resource
      #
      # @api private
      module SingleResource
        # @see Document#to_hash
        def to_hash(options = {})
          document  = super(Options::Include.(options, mappings))
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

        private

        def mappings
          @mappings ||= begin
            mappings = {}
            mappings[:id]             = find_id_mapping
            mappings[:relationships]  = find_relationship_mappings
            mappings[:relationships]['_self'] = self.class.type
            mappings
          end
        end

        def find_id_mapping
          self.class.definitions.detect { |definition|
            definition[:as] && definition[:as].(:value) == 'id'
          }.name
        end

        def find_relationship_mappings
          included_definitions = self.class.definitions['included'].representer_module.definitions
          included_definitions.each_with_object({}) do |definition, hash|
            hash[definition.name] = definition.representer_module.type
          end
        end
      end
    end
  end
end
