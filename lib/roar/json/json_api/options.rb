module Roar
  module JSON
    module JSONAPI
      # @api private
      module Options
        # Transforms `field:` and `include:`` options to their internal
        # equivalents.
        #
        # @see Document#to_hash
        class Include
          DEFAULT_INTERNAL_INCLUDES = [:id, :attributes, :relationships].freeze

          def self.call(options, mappings)
            new.(options, mappings)
          end

          def call(options, mappings)
            include, fields = *options.values_at(:include, :fields)
            return options if options[:_json_api_parsed] || !(include || fields)

            internal_options = {}
            rewrite_include_option!(internal_options, include)
            rewrite_fields!(internal_options, fields, mappings)

            options.reject { |key, _| [:include, :fields].include?(key) }
                   .merge(internal_options)
          end

          private

          def rewrite_include_option!(options, include)
            include_paths = (include || []).map { |path|
              path.to_s.split('.').map(&:to_sym)
            }

            options[:include]  = DEFAULT_INTERNAL_INCLUDES + [:included]
            options[:included] = { include: include_paths.map(&:first) - [:_self] }
            include_paths.each do |include_path|
              options[:included].merge!(explode_include_path(*include_path))
            end
            options
          end

          def rewrite_fields!(options, fields, mappings)
            (fields || []).each do |type, value|
              relationship_name = mappings.key(type) || type
              if relationship_name == :_self
                options[:attributes]     = { include: value }
                options[:relationships]  = { include: value }
              else
                options[:included][relationship_name] ||= {}
                options[:included][relationship_name].merge!(
                  attributes:       { include: value },
                  relationships:    { include: value },
                  _json_api_parsed: true # flag to halt recursive parsing
                )
              end
            end
          end

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
    end
  end
end
