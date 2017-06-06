class SimpleSingleResourceObjectDecorator < Roar::Decorator
  include Roar::JSON

  property :title
end
