# encoding: utf-8

require 'test_helper'
require 'roar/json/json_api'
require 'json'

class ResourceLinkageTest < MiniTest::Spec
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

    has_one   :chef,        decorator: ChefDecorator
    has_many  :ingredients, decorator: IngredientDecorator

    has_many  :reviews do
      type :review

      attributes do
        property :text
      end
    end
  end

  Recipe      = Struct.new(:id, :name, :chef, :ingredients, :reviews)
  Chef        = Struct.new(:id, :name)
  Ingredient  = Struct.new(:id, :name)

  let(:doc)               { RecipeDecorator.new(souffle).to_hash }
  let(:doc_relationships) { doc['data']['relationships'] }

  describe 'non-empty relationships' do
    let(:souffle) {
      Recipe.new(1, 'Cheese soufflé',
                 Chef.new(1, 'Jamie Oliver'),
                 [Ingredient.new(5, 'Eggs'), Ingredient.new(6, 'Gruyère')])
    }

    it 'renders a single object for non-empty to-one relationships' do
      doc_relationships['chef'].must_equal('data'=>{ 'type' => 'chefs', 'id' => '1' })
    end

    it 'renders an array for non-empty to-many relationships' do
      doc_relationships['ingredients'].must_equal('data' => [
                                                    { 'type' => 'ingredients', 'id' => '5' },
                                                    { 'type' => 'ingredients', 'id' => '6' }
                                                  ])
    end
  end

  describe 'empty (nil) relationships' do
    let(:souffle) { Recipe.new(1, 'Cheese soufflé', nil, nil) }

    it 'renders null for an empty to-one relationships' do
      doc_relationships['chef'].must_equal('data' => nil)
    end

    it 'renders an empty array ([]) for empty (nil) to-many relationships' do
      doc_relationships['ingredients'].must_equal('data' => [])
    end
  end

  describe 'empty to-many relationships' do
    let(:souffle) { Recipe.new(1, 'Cheese soufflé', nil, []) }

    it 'renders an empty array ([]) for empty to-many relationships' do
      doc_relationships['ingredients'].must_equal('data' => [])
    end
  end
end
