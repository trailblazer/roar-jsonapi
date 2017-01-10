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

  describe 'with empty :include option' do
    it 'rewrites :include' do
      options = Include.({ include: [] }, {})
      options.must_equal(include:  [:id, :attributes, :relationships, :included],
                         included: { include: [] })
    end
  end

  describe 'with empty :include option and non-empty :fields option' do
    it 'parses :fields (_self), but does not include other resources' do
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

    it 'parses :fields, but does not include other resources' do
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
    it 'rewrites :include given a relationship name' do
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

    it 'rewrites :include given a dot-separated path of relationship names' do
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

    it 'does not rewrite :include if _json_api_parsed: true' do
      options = Include.({ include:          [:id, :attributes],
                           _json_api_parsed: true }, {})
      options.must_equal(include:          [:id, :attributes],
                         _json_api_parsed: true)
    end
  end

  describe 'with falsey :include options' do
    it 'does not rewrite include: false' do
      options = Include.({ include: false }, {})
      options.must_equal(include: false)
    end

    it 'does not rewrite include: nil' do
      options = Include.({ include: nil }, {})
      options.must_equal(include: nil)
    end
  end

  describe 'with falsey :fields options' do
    it 'does not parse fields: nil' do
      options = Include.({ fields: nil }, {})
      options.must_equal(fields: nil)
    end
  end
end
