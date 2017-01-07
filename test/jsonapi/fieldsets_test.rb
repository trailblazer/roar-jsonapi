require 'test_helper'
require 'roar/json/json_api'
require 'json'

class JSONAPIFieldsetsTest < Minitest::Spec
  Article = Struct.new(:id, :title, :summary, :comments, :author)
  Comment = Struct.new(:id, :body, :good)
  Author = Struct.new(:id, :name, :email)

  let(:comments) { [Comment.new('c:1', 'Cool!', true), Comment.new('c:2', 'Nah', false)] }

  describe 'Single Resource Object With Options' do
    class DocumentSingleResourceObjectDecorator < Roar::Decorator
      include Roar::JSON::JSONAPI
      type :articles

      attributes do
        property :title
        property :summary
      end

      has_many :comments do
        type :comments

        attributes do
          property :body
          property :good
        end
      end

      has_one :author do
        type :authors

        attributes do
          property :name
          property :email
        end
      end
    end

    let(:article) { Article.new(1, 'My Article', 'An interesting read.', comments, Author.new('a:1', 'Celso', 'celsito@trb.to')) }

    it 'includes scalars' do
      DocumentSingleResourceObjectDecorator.new(article)
                                           .to_json(attributes:    { include: [:title] },
                                                    included:      { include: [] },
                                                    relationships: { include: [] })
                                           .must_equal_json(%(
          {
            "data": {
              "id": "1",
              "attributes": {
                "title": "My Article"
              },
              "type": "articles"
            }
          }
        ))
    end

    it 'includes compound objects' do
      DocumentSingleResourceObjectDecorator.new(article)
                                           .to_json(
                                             attributes:    { include: [:id, :title] },
                                             included:      { include: [:comments] },
                                             relationships: { include: [] }
                                           )
                                           .must_equal_json(%(
          {
            "data": {
              "id": "1",
              "attributes": {
                "title": "My Article"
              },
              "type": "articles"
            },
            "included": [
              {
                "type": "comments",
                "id": "c:1",
                "attributes": {
                  "body": "Cool!",
                  "good": true
                }
              },
              {
                "type": "comments",
                "id": "c:2",
                "attributes": {
                  "body": "Nah",
                  "good": false
                }
              }
            ]
          }
        ))
    end

    it 'includes other compound objects' do
      DocumentSingleResourceObjectDecorator.new(article)
                                           .to_json(attributes:    { include: [:title] },
                                                    included:      { include: [:author] },
                                                    relationships: { include: [] })
                                           .must_equal_json(%(
          {
            "data": {
              "id": "1",
              "attributes": {
                "title": "My Article"
              },
              "type": "articles"
            },
            "included": [
              {
                "type": "authors",
                "id": "a:1",
                "attributes": {
                  "email": "celsito@trb.to",
                  "name": "Celso"
                }
              }
            ]
          }
        ))
    end

    describe 'collection' do
      it 'supports :includes' do
        DocumentSingleResourceObjectDecorator.for_collection.new([article])
                                             .to_hash(attributes:    { include: [:title] },
                                                      included:      { include: [:author] },
                                                      relationships: { include: [] })
                                             .must_equal Hash[{
                                               'data'     => [
                                                 { 'type'       => 'articles',
                                                   'id'         => '1',
                                                   'attributes' => { 'title'=>'My Article' } }
                                               ],
                                               'included' =>
                                                             [{ 'type' => 'authors', 'id' => 'a:1', 'attributes' => { 'name' => 'Celso', 'email' => 'celsito@trb.to' } }]
                                             }]
      end

      # include: ROAR API
      it 'blaaaaaaa' do
        skip 'rework included API'
        DocumentSingleResourceObjectDecorator.for_collection.new([article])
                                             .to_hash(
                                               attributes:    { include: [:title] },
                                               included:      { include: { author: [:email] } },
                                               relationships: { include: [] }
                                             )
                                             .must_equal Hash[{
                                               'data'     => [
                                                 { 'type'       => 'articles',
                                                   'id'         => '1',
                                                   'attributes' => { 'title'=>'My Article' } }
                                               ],
                                               'included' =>
                                                             [{ 'type' => 'author', 'id' => 'a:1', 'attributes' => { 'email'=>'celsito@trb.to' } }]
                                             }]
      end
    end
  end

  describe 'Collection Resources With Options' do
    class CollectionResourceObjectDecorator < Roar::Decorator
      include Roar::JSON::JSONAPI
      type :articles

      attributes do
        property :title
        property :summary
      end
    end

    let(:document) {
      %({
        "data": [
          {
            "id": "1",
            "attributes": {
              "title": "My Article"
            },
            "type": "articles"
          },
          {
            "id": "2",
            "attributes": {
              "title": "My Other Article"
            },
            "type": "articles"
          }
        ]
      })
    }

    it do
      CollectionResourceObjectDecorator.for_collection.new([
                                                             Article.new(1, 'My Article', 'An interesting read.'),
                                                             Article.new(2, 'My Other Article', 'An interesting read.')
                                                           ]).to_json(attributes: { include: [:title] }).must_equal_json document
    end
  end
end
