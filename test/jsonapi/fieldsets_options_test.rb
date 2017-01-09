require 'test_helper'
require 'roar/json/json_api'

class FieldsetsOptionsTest < Minitest::Spec
  Include = Roar::JSON::JSONAPI::Options::Include

  describe 'with non-empty :include and non-empty :fields option' do
    it 'rewrites :include and parses :fields' do
      options = Include.({
                           include: [:articles],
                           fields:  { articles: [:title, :body], people: [] }
                         },
                         articles: :articles)
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
                             attributes:       { include: [] },
                             relationships:    { include: [] },
                             _json_api_parsed: true
                           }
                         })
    end
  end

  describe 'with empty :include option and non-empty :fields option' do
    it 'parses :fields option (_self), but does not include other resources' do
      options = Include.({
                           include: [],
                           fields:  { articles: [:title, :body], people: [] }
                         },
                         _self: :articles)
      options.must_equal(include:       [:id, :attributes, :relationships, :included],
                         included:      {
                           include: [],
                           people:  {
                             attributes:       { include: [] },
                             relationships:    { include: [] },
                             _json_api_parsed: true
                           }
                         },
                         attributes:    { include: [:title, :body] },
                         relationships: { include: [:title, :body] })
    end

    it 'parses :fields option, but does not include other resources' do
      options = Include.({
                           include: [],
                           fields:  { articles: [:title, :body], people: [:email] }
                         },
                         author: :people, articles: :articles)
      options.must_equal(include:  [:id, :attributes, :relationships, :included],
                         included: {
                           include:  [],
                           articles: {
                             attributes:       { include: [:title, :body] },
                             relationships:    { include: [:title, :body] },
                             _json_api_parsed: true
                           },
                           author:   {
                             attributes:       { include: [:email] },
                             relationships:    { include: [:email] },
                             _json_api_parsed: true
                           }
                         })
    end
  end

  describe 'with non-empty :include option' do
    it 'rewrites :include option: relationship name' do
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

    it 'rewrites :include option: dot-separated path of relationship names' do
      options = Include.({ include: ['comments.author.employer'] }, {})
      options.must_equal(include:  [:id, :attributes, :relationships, :included],
                         included: {
                           include:  [:comments],
                           comments: {
                             include:          [:id, :attributes, :relationships, :included],
                             included:         {
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
end
