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
        # @example Rendering with compound documents and sparse fieldsets
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
        # @option options [Array<#to_s>,#to_s,false] include
        #   compound documents to include, specified as a list of relationship
        #   paths (Array or comma-separated String) or `false`, if no compound
        #   documents are to be included.
        #
        #   N.B. this syntax and behaviour for this option *is signficantly
        #   different* to that of the `include` option implemented in other,
        #   non-JSON API Representers.
        # @option options [Hash{Symbol=>[Array<String>]}] fields
        #   fields to returned on a per-type basis.
        # @option options [Hash{#to_s}=>Object] meta
        #   additional meta information to be rendered in the document.
        # @option options [Hash{Symbol=>Symbol}] user_options
        #   additional arbitary options to be passed to the Representer.
        #
        # @return [Hash{String=>Object}]
        #
        # @api public
        def to_hash(options = {})
          super
        end
      end
    end
  end
end
