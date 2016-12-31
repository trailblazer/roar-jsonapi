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
          res = super(Options::Include.(options, self))

          links = Renderer::Links.new.(res, options)
          meta  = render_meta(options)

          relationships = render_relationships(res)
          included      = render_included(res)

          document = {
            data: data = {
              type: self.class.type,
              id:   res.delete('id').to_s
            }
          }
          data[:attributes]    = res unless res.empty?
          data[:relationships] = relationships if relationships && relationships.any?

          Fragment::Links.(data, links, options)
          Fragment::Included.(document, included, options)
          Fragment::Meta.(document, meta, options)

          document
        end

        def from_hash(hash, _options = {})
          super(from_document(hash))
        end

        private

        def from_document(hash)
          return {} unless hash['data'] # DISCUSS: Is failing silently here a good idea?
          # hash: {"data"=>{"type"=>"articles", "attributes"=>{"title"=>"Ember Hamster"}, "relationships"=>{"author"=>{"data"=>{"type"=>"people", "id"=>"9"}}}}}
          attributes = hash['data']['attributes'] || {}
          attributes['relationships'] = {}

          hash['data'].fetch('relationships', []).each do |rel, fragment|
            attributes['relationships'][rel] = fragment['data'] # DISCUSS: we could use a relationship representer here (but only if needed elsewhere).
          end

          # this is the format the object representer understands.
          attributes # {"title"=>"Ember Hamster", "author"=>{"type"=>"people", "id"=>"9"}}
        end

        # Go through {"album"=>{"title"=>"Hackers"}, "musicians"=>[{"name"=>"Eddie Van Halen"}, ..]} from linked:
        # and wrap every item in an array.
        def render_included(res)
          return unless (compound = res.delete('included'))

          compound.collect { |_name, hash|
            if hash.is_a?(::Hash)
              hash[:data]
            else
              hash.collect { |item| item[:data] }
            end
          }.flatten
        end

        def render_meta(options)
          representer = representable_attrs[:meta_representer]
          meta        = representer ? representer.new(represented).to_hash : {}
          meta.merge!(options['meta']) if options['meta']
          meta
        end

        def render_relationships(res)
          (res['relationships'] || []).each do |name, hash|
            if hash.is_a?(::Hash)
              hash[:links] = hash[:data].delete(:links) if hash[:data].key? :links
            else # hash => [{data: {}}, ..]
              res['relationships'][name] = collection = { data: [] }
              hash.each do |hsh|
                collection[:links] = hsh[:data].delete(:links) if hsh[:data].key? :links
                collection[:data] << hsh[:data]
              end
            end
          end
          res.delete('relationships')
        end
      end
    end
  end
end
