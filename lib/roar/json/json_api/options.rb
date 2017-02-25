module Roar
  module JSON
    module JSONAPI
      # @api private
      module Options
        # Transforms `field:` and `include:`` options to their internal
        # equivalents.
        #
        # @see SingleResource#to_hash
        class Include
          DEFAULT_INTERNAL_INCLUDES = [:attributes, :relationships].freeze

          def self.call(options, mappings)
            new.(options, mappings)
          end

          def call(options, mappings)
            include, fields = *options.values_at(:include, :fields)
            return options if options[:_json_api_parsed] || !(include || fields)

            internal_options = {}
            rewrite_include_option!(internal_options, include,
                                    mappings.fetch(:id, :id))
            rewrite_fields!(internal_options, fields,
                            mappings.fetch(:relationships, {}))

            options.reject { |key, _| [:include, :fields].include?(key) }
                   .merge(internal_options)
          end

          private

          def rewrite_include_option!(options, include, id_mapping)
            include_paths      = parse_include_option(include)
            default_includes   = [id_mapping.to_sym] + DEFAULT_INTERNAL_INCLUDES
            options[:include]  = default_includes + [:included]
            options[:included] = { include: include_paths.map(&:first) - [:_self] }
            include_paths.each do |include_path|
              options[:included].merge!(
                explode_include_path(*include_path, default_includes)
              )
            end
            options
          end

          def rewrite_fields!(options, fields, rel_mappings)
            (fields || {}).each do |type, raw_value|
              fields_value      = parse_fields_value(raw_value)
              relationship_name = (rel_mappings.key(type.to_s) || type).to_sym
              if relationship_name == :_self
                options[:attributes]     = { include: fields_value }
                options[:relationships]  = { include: fields_value }
              else
                options[:included][relationship_name] ||= {}
                options[:included][relationship_name].merge!(
                  attributes:       { include: fields_value },
                  relationships:    { include: fields_value },
                  _json_api_parsed: true # flag to halt recursive parsing
                )
              end
            end
          end

          def parse_include_option(include_value)
            Array(include_value).flat_map { |i| i.to_s.split(',') }.map { |path|
              path.split('.').map(&:to_sym)
            }
          end

          def parse_fields_value(fields_value)
            Array(fields_value).flat_map { |v| v.to_s.split(',') }.map(&:to_sym)
          end

          def explode_include_path(*include_path, default_includes)
            head, *tail = *include_path
            hash        = {}
            result      = hash[head] ||= {
              include: default_includes.dup, _json_api_parsed: true
            }

            tail.each do |key|
              break unless result[:included].nil?

              result[:include] << :included
              result[:included] ||= {}

              result = result[:included][key] ||= {
                include: default_includes.dup, _json_api_parsed: true
              }
            end

            hash
          end
        end
      end
    end
  end
end
