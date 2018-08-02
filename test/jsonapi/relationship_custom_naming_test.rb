require 'test_helper'

class RelationshipCustomNameTest < MiniTest::Spec
  class ChefDecorator < Roar::Decorator
    include Roar::JSON::JSONAPI.resource :chefs

    attributes do
      property :name
    end
  end

  class IngredientDecorator < Roar::Decorator
    include Roar::JSON::JSONAPI.resource :ingredients

    attributes do
      property :name
    end
  end

  class RecipeDecorator < Roar::Decorator
    include Roar::JSON::JSONAPI.resource :recipes

    attributes do
      property :name
    end

    has_one   :best_chef,        as: "bestChefEver", extend: ChefDecorator
    has_many  :best_ingredients, as: "bestIngridients", extend: IngredientDecorator
  end

  Recipe      = Struct.new(:id, :name, :best_chef, :best_ingredients, :reviews)
  Chef        = Struct.new(:id, :name)
  Ingredient  = Struct.new(:id, :name)

  let(:doc)               { RecipeDecorator.new(souffle).to_hash }
  let(:doc_relationships) { doc['data']['relationships'] }
  describe 'non-empty relationships' do
    let(:souffle) {
      Recipe.new(1, 'Cheese Muffins',
                 Chef.new(1, 'Jamie Oliver'),
                 [Ingredient.new(5, 'Eggs'), Ingredient.new(6, 'Gruyère')])
    }

    it 'renders a single object for non-empty to-one relationships with custom name' do
      doc_relationships['best_chef'].must_be_nil
      doc_relationships['bestChefEver'].wont_be_nil
    end

    it 'renders an array for non-empty to-many relationships with custom name' do
      doc_relationships['best_ingredients'].must_be_nil
      doc_relationships['bestIngridients'].wont_be_nil
    end
  end
end
