module Roar
  module JSON
    module JSONAPI
      module Defaults
        def self.included(base)
          base.defaults do |name, _|
            { as: JSONAPI::MemberName.(name) }
          end
        end
      end
    end
  end
end
