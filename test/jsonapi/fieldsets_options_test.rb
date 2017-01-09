require 'test_helper'
require 'roar/json/json_api'

class FieldsetsOptionsTest < Minitest::Spec
  Include = Roar::JSON::JSONAPI::Options::Include

  it 'rewrites JSON API fields: and includes: options' do
    options = Include.({
                         include: [:articles],
                         fields:  { articles: [:title, :body], people: [] }
                       }, {})
    options.must_equal(include:  [:id, :attributes, :relationships, :included],
                       included: {
                         include:  [:articles],
                         articles: {
                           include:          [:id, :attributes, :relationships],
                           attributes:       { include: [:title, :body] },
                           relationships:    { include: [:title, :body] },
                           _json_api_parsed: true
                         },
                         people:   {
                           include:          [:id, :attributes, :relationships],
                           attributes:       { include: [] },
                           relationships:    { include: [] },
                           _json_api_parsed: true
                         }
                       })
  end

  it 'maps _self to a type' do
    options = Include.({
                         include: [],
                         fields:  { articles: [:title, :body], people: [] }
                       },
                       _self: :articles)
    options.must_equal(include:       [:id, :attributes, :relationships, :included],
                       included:      {
                         include: [],
                         people:  {
                           include:          [:id, :attributes, :relationships],
                           attributes:       { include: [] },
                           relationships:    { include: [] },
                           _json_api_parsed: true
                         }
                       },
                       attributes:    { include: [:title, :body] },
                       relationships: { include: [:title, :body] })
  end

  it 'maps a relationship name to a type' do
    options = Include.({
                         include: [:author],
                         fields:  { articles: [:title, :body], people: [:email] }
                       },
                       author: :people)
    options.must_equal(include:  [:id, :attributes, :relationships, :included],
                       included: {
                         include:  [:author],
                         articles: {
                           include:          [:id, :attributes, :relationships],
                           attributes:       { include: [:title, :body] },
                           relationships:    { include: [:title, :body] },
                           _json_api_parsed: true
                         },
                         author:   {
                           include:          [:id, :attributes, :relationships],
                           attributes:       { include: [:email] },
                           relationships:    { include: [:email] },
                           _json_api_parsed: true
                         }
                       })
  end

  it 'rewrites a relationship name' do
    options = Include.({ include: ['comments'] }, {})
    options.must_equal(include:  [:id, :attributes, :relationships, :included],
                       included: {
                         include:  [:comments],
                         comments: {
                           include:          [:id, :attributes, :relationships],
                           _json_api_parsed: true
                         }
                       })
  end

  it 'rewrites a dot-separated path of relationship names' do
    options = Include.({ include: ['comments.author.employer'] }, {})
    options.must_equal(include:  [:id, :attributes, :relationships, :included],
                       included: {
                         include:  [:comments],
                         comments: {
                           include:  [:id, :attributes, :relationships, :included],
                           included: {
                             author: {
                               include:          [:id, :attributes, :relationships, :included],
                               included:         {
                                 employer: {
                                   include:          [:id, :attributes, :relationships],
                                   _json_api_parsed: true
                                 }
                               },
                               _json_api_parsed: true
                             }
                           },
                           _json_api_parsed: true
                         }
                       })
  end
end
