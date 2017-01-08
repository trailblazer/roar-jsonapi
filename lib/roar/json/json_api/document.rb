module Roar
  module JSON
    module JSONAPI
      # Instance method API for JSON API Documents.
      #
      module Document
        # Render the document as JSON
        #
        # @example Simple rendering
        #   representer.to_json
        #
        # @example Rendering with compount documents and sparse fieldsets
        #   uri   = Addressable::URI.parse('/articles/1?include=author,comments.author')
        #   query = Rack::Utils.parse_nested_query(uri.query)
        #   # => {"include"=>"author", "fields"=>{"articles"=>"title,body", "people"=>"name"}}
        #
        #   representer.to_json(
        #     include: query['include'],
        #     fields:  query['fields']
        #   )
        #
        # @option options (see #to_hash)
        #
        # @return [String] JSON String
        #
        # @see http://jsonapi.org/format/#fetching-includes
        # @see http://jsonapi.org/format/#fetching-sparse-fieldsets
        # @api public
        def to_json(options = {})
          super
        end

        # Render the document as a Ruby Hash
        #
        # @option options [Array<#to_s>,#to_s,Boolean] include
        #   compound documents to include, specified as a list of relationship
        #   paths (Array or comma-separated String) or `false`, if no compound
        #   documents are to be included.
        #
        #   N.B. this syntax and behaviour for this option *is signficantly
        #   different* to that of the `include` option implemented in other,
        #   non-JSON API Representers.
        # @option options [Hash{Symbol=>[Array<String>]}] fields
        #   fields to returned on a per-type basis.
        # @option options [Hash{Symbol=>Symbol}] user_options
        #   additional arbitary options to be passed to the Representer.
        #
        # @return [Hash{String=>Object}]
        #
        # @api public
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
            definition[:as] && definition[:as].evaluate(:value) == 'id'
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
