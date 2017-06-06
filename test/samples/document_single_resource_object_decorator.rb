class DocumentSingleResourceObjectDecorator < Roar::Decorator
  include Roar::JSON::JSONAPI.resource :articles

  attributes do
    property :title
  end
end
