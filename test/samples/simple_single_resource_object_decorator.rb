class SimpleSingleResourceObjectDecorator < Representable::Decorator
  include Representable::JSON

  property :title
end
