module Roar
  module JSON
    module JSONAPI
      # {:include=>[:id, :title, :author, :included],
      #  :included=>{:include=>[:author], :author=>{:include=>[:email, :id]}}}
      module Options
        class Include
          DEFAULT_INTERNAL_INCLUDES = [:id, :attributes, :relationships].freeze

          def self.call(options, mappings)
            new.(options, mappings)
          end

          def call(options, mappings)
            include, fields = *options.values_at(:include, :fields)
            return options if options[:_json_api_parsed] || !(include || fields)

            include_paths = (include || []).map { |path| path.to_s.split('.').map(&:to_sym) }

            internal_options = {}
            internal_options[:include]  = DEFAULT_INTERNAL_INCLUDES + [:included]
            internal_options[:included] = { include: include_paths.map(&:first) - [:_self] }
            include_paths.each do |include_path|
              internal_options[:included].merge!(explode_include_path(*include_path))
            end

            (fields || []).each do |type, value|
              if mappings.key(type) == :_self
                internal_options[:attributes]     = { include: value }
                internal_options[:relationships]  = { include: value }
              else
                relationship_name = mappings.key(type) || type
                internal_options[:included][relationship_name] = {
                  include:          DEFAULT_INTERNAL_INCLUDES.dup,
                  attributes:       { include: value },
                  relationships:    { include: value },
                  _json_api_parsed: true # flag to halt recursive parsing
                }
              end
            end

            options.select { |key, _| ![:fields, :include].include?(key) }
                   .merge(internal_options)
          end

          private

          def explode_include_path(*include_path)
            head, *tail = *include_path
            hash        = {}
            result      = hash[head] ||= {
              include: DEFAULT_INTERNAL_INCLUDES.dup, _json_api_parsed: true
            }

            tail.each do |key|
              break unless result[:included].nil?

              result[:include] << :included
              result[:included] ||= {}

              result = result[:included][key] ||= {
                include: DEFAULT_INTERNAL_INCLUDES.dup, _json_api_parsed: true
              }
            end

            hash
          end
        end
      end

      module Document
        # rubocop:disable Metrics/MethodLength
        def to_hash(options = {})
          document  = super(Options::Include.(options, relationship_type_mappings))
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
