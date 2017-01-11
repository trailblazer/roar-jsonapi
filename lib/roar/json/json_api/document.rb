module Roar
  module JSON
    module JSONAPI
      # Instance method API for JSON API Documents.
      #
      module Document
        # Render the document as JSON
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
        # @option options [Boolean,Array<String>] include
        #   compound documents to include, specified as a list of relationship
        #   paths or `false`, if no compound documents are to be included.
        #
        #   N.B. this syntax and behaviour for this option is different to that
        #   of the `include` option implemented in non-JSON API Representers.
        # @option options [Hash{Symbol=>[Array<String>]}] fields
        #   fields to returned on a per-type basis.
        # @option options [Hash{Symbol=>Symbol}] user_options
        #   additional arbitary options to be passed to the Representer.
        #
        # @return [Hash{String=>Object}]
        #
        # @api public
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
