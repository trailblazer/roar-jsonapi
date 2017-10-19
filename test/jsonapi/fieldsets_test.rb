require 'test_helper'
require 'roar/json/json_api'
require 'json'

class JSONAPIFieldsetsTest < Minitest::Spec
  Article = Struct.new(:id, :title, :summary, :comments, :author)
  Comment = Struct.new(:id, :body, :good, :comment_author)
  Author = Struct.new(:id, :name, :email)

  describe 'Single Resource Object With Options' do
    class DocumentSingleResourceObjectDecorator < Roar::Decorator
      include Roar::JSON::JSONAPI.resource :articles

      attributes do
        property :title
        property :summary
      end

      has_many :comments do
        attributes do
          property :body
          property :good
        end

        has_one :comment_author, class: Comment do
          type :authors

          attributes do
            property :name
            property :email
          end
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

    let(:comments) {
      [
        Comment.new('c:1', 'Cool!', true,
                    Author.new('a:2', 'Tim', 'troll@trollblazer.io')),
        Comment.new('c:2', 'Nah', false)
      ]
    }

    let(:article) {
      Article.new(1, 'My Article', 'An interesting read.', comments,
                  Author.new('a:1', 'Celso', 'celsito@trb.to'))
    }

    it 'includes scalars' do
      DocumentSingleResourceObjectDecorator.new(article)
                                           .to_json(
                                             fields: { articles: 'title' }
                                           )
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
                                             fields:  { articles: 'title' },
                                             include: :comments
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
                },
                "relationships": {
                  "comment-author": {
                    "data": {
                      "type": "authors",
                      "id": "a:2"
                    }
                  }
                }
              },
              {
                "type": "comments",
                "id": "c:2",
                "attributes": {
                  "body": "Nah",
                  "good": false
                },
                "relationships": {
                  "comment-author": {
                    "data": null
                  }
                }
              }
            ]
          }
        ))
    end

    it 'includes nested compound objects' do
      DocumentSingleResourceObjectDecorator.new(article)
                                           .to_json(
                                             fields:  { articles: 'title' },
                                             include: 'comments.author'
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
                },
                "relationships": {
                  "comment-author": {
                    "data": {
                      "type": "authors",
                      "id": "a:2"
                    }
                  }
                },
                "included": [
                  {
                    "type": "authors",
                    "id": "a:2",
                    "attributes": {
                      "email": "troll@trollblazer.io",
                      "name": "Tim"
                    }
                  }
                ]
              },
              {
                "type": "comments",
                "id": "c:2",
                "attributes": {
                  "body": "Nah",
                  "good": false
                },
                "relationships": {
                  "comment-author": {
                    "data": null
                  }
                }
              }
            ]
          }
        ))
    end

    it 'includes other compound objects' do
      DocumentSingleResourceObjectDecorator.new(article)
                                           .to_json(
                                             fields:  { articles: 'title' },
                                             include: :author
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
                                             .to_hash(
                                               fields:  { articles: 'title' },
                                               include: :author
                                             )
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
        DocumentSingleResourceObjectDecorator.for_collection.new([article])
                                             .to_hash(
                                               fields:  { articles: 'title', authors: [:email] },
                                               include: :author
                                             )
                                             .must_equal Hash[{
                                               'data'     => [
                                                 { 'type'       => 'articles',
                                                   'id'         => '1',
                                                   'attributes' => { 'title'=>'My Article' } }
                                               ],
                                               'included' =>
                                                             [{ 'type' => 'authors', 'id' => 'a:1', 'attributes' => { 'email'=>'celsito@trb.to' } }]
                                             }]
      end
    end
  end

  describe 'Collection Resources With Options' do
    class CollectionResourceObjectDecorator < Roar::Decorator
      include Roar::JSON::JSONAPI.resource :articles

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
                                                           ]).to_json(
                                                             fields: { articles: :title }
                                                           ).must_equal_json document
    end
  end

  describe 'Document with given id_key and nested resources with default id_key' do
    class DocumentResourceWithDifferentIdAtRoot < Roar::Decorator
      include Roar::JSON::JSONAPI.resource :articles, id_key: :article_id

      attributes do
        property :title
        property :summary
      end

      has_many(:comments) do
        attributes do
          property :body
          property :good
        end
      end
    end

    let(:comments) {
      [
        Comment.new('c:1', 'Cool!', true,
                    Author.new('a:2', 'Tim', 'troll@trollblazer.io')),
        Comment.new('c:2', 'Nah', false)
      ]
    }

    let(:article) {
      klass = Struct.new(:article_id, :title, :summary, :comments, :author)
      klass.new(1, 'My Article', 'An interesting read.', comments,
                  Author.new('a:1', 'Celso', 'celsito@trb.to'))
    }

    let(:document) {
      %({
        "data": {
          "id": "1",
          "attributes": {
            "summary": "An interesting read.",
            "title": "My Article"
          },
          "type": "articles",
          "relationships": {
            "comments": {
              "data": [
                {
                  "id": "c:1",
                  "type": "comments"
                },
                {
                  "id": "c:2",
                  "type": "comments"
                }
              ]
            }
          }
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
      })
    }

    it do
      DocumentResourceWithDifferentIdAtRoot.new(article).to_json(include: 'comments')
                                           .must_equal_json document
    end
  end

  describe 'Document with default id_key and nested resources with given id_key' do
    class CommentDecorator < Roar::Decorator
      include Roar::JSON::JSONAPI.resource :comments, id_key: :comment_id

      attributes do
        property :body
        property :good
      end
    end

    class DocumentResourceWithDifferentIdAtRelation < Roar::Decorator
      include Roar::JSON::JSONAPI.resource :articles

      attributes do
        property :title
        property :summary
      end

      has_many :comments, decorator: CommentDecorator
    end

    let(:comments) {
      klass = Struct.new(:comment_id, :body, :good, :comment_author)
      [
        klass.new('c:1', 'Cool!', true,
                  Author.new('a:2', 'Tim', 'troll@trollblazer.io')),
        klass.new('c:2', 'Nah', false)
      ]
    }

    let(:article) {
      Article.new(1, 'My Article', 'An interesting read.', comments,
                  Author.new('a:1', 'Celso', 'celsito@trb.to'))
    }

    let(:document) {
      %({
        "data": {
          "id": "1",
          "attributes": {
            "summary": "An interesting read.",
            "title": "My Article"
          },
          "type": "articles",
          "relationships": {
            "comments": {
              "data": [
                {
                  "id": "c:1",
                  "type": "comments"
                },
                {
                  "id": "c:2",
                  "type": "comments"
                }
              ]
            }
          }
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
      })
    }

    it do
      DocumentResourceWithDifferentIdAtRelation.new(article).to_json(include: 'comments')
                                               .must_equal_json document
    end
  end
end
