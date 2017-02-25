module Roar
  module JSON
    module JSONAPI
      # Instance method API for JSON API Documents representing an array of Resources
      #
      # @api private
      module ResourceCollection
        # @see Document#to_hash
        def to_hash(options = {})
          document = super(to_a: options, user_options: options[:user_options]) # [{data: {..}, data: {..}}]

          links = Renderer::Links.new.(document, options)
          meta  = render_meta(options)
          included = []
          document['data'].each do |single|
            included += single.delete('included') || []
          end

          HashUtils.store_if_any(document, 'included',
                                 Fragment::Included.(included, options))
          HashUtils.store_if_any(document, 'links',    links)
          HashUtils.store_if_any(document, 'meta',     meta)

          document
        end
      end
    end
  end
end
