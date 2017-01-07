require "test_helper"
require "roar/json/json_api"
require "json"

class JsonapiRenderTest < MiniTest::Spec
  let (:article) { Article.new(1, "Health walk", Author.new(2), Author.new("editor:1"), [Comment.new("comment:1", "Ice and Snow"),Comment.new("comment:2", "Red Stripe Skank")]) }
  let (:decorator) { ArticleDecorator.new(article) }

  it "renders full document" do
    json = decorator.to_json
    json.must_equal_json(%({
      "data": {
        "id": "1",
        "relationships": {
          "author": {
            "data": {
              "id": "2",
              "type": "authors"
            },
            "links": {
              "self": "/articles/1/relationships/author",
              "related": "/articles/1/author"
            }
          },
          "editor": {
            "data": {
              "id": "editor:1",
              "type": "editors"
            },
            "meta": {
              "peer_reviewed": false
            }
          },
          "comments": {
            "data": [{
              "id": "comment:1",
              "type": "comments"
            }, {
              "id": "comment:2",
              "type": "comments"
            }],
            "links": {
              "self": "/articles/1/relationships/comments",
              "related": "/articles/1/comments"
            },
            "meta": {
              "comment-count": 5
            }
          }
        },
        "attributes": {
          "title": "Health walk"
        },
        "type": "articles",
        "links": {
          "self": "http://Article/1"
        }
      },
      "included": [{
        "id": "2",
        "type": "authors",
        "links": {
          "self": "http://authors/2"
        }
      }, {
        "id": "editor:1",
        "type": "editors"
      }, {
        "id": "comment:1",
        "attributes": {
          "body": "Ice and Snow"
        },
        "type": "comments",
        "links": {
          "self": "http://comments/comment:1"
        }
      }, {
        "id": "comment:2",
        "attributes": {
          "body": "Red Stripe Skank"
        },
        "type": "comments",
        "links": {
          "self": "http://comments/comment:2"
        }
      }],
      "meta": {
        "reviewers": ["Christian Bernstein"],
        "reviewer_initials": "C.B."
      }
    }))
  end

  it "included: false suppresses compound docs" do
    json = decorator.to_json(included: false)
    json.must_equal_json(%({
      "data": {
        "id": "1",
        "relationships": {
          "author": {
            "data": {
              "id": "2",
              "type": "authors"
            },
            "links": {
              "self": "/articles/1/relationships/author",
              "related": "/articles/1/author"
            }
          },
          "editor": {
            "data": {
              "id": "editor:1",
              "type": "editors"
            },
            "meta": {
              "peer_reviewed": false
            }
          },
          "comments": {
            "data": [{
              "id": "comment:1",
              "type": "comments"
            }, {
              "id": "comment:2",
              "type": "comments"
            }],
            "links": {
              "self": "/articles/1/relationships/comments",
              "related": "/articles/1/comments"
            },
            "meta": {
              "comment-count": 5
            }
          }
        },
        "attributes": {
          "title": "Health walk"
        },
        "type": "articles",
        "links": {
          "self": "http://Article/1"
        }
      },
      "meta": {
        "reviewers": ["Christian Bernstein"],
        "reviewer_initials": "C.B."
      }
    }))
  end

  it 'renders additional meta information if meta option supplied' do
    hash = decorator.to_hash('meta' => {
      'copyright' => 'Nick Sutterer', 'reviewers' => []
    })
    hash['meta']['copyright'].must_equal('Nick Sutterer')
    hash['meta']['reviewers'].must_equal([])
    hash['meta']['reviewer_initials'].must_equal('C.B.')
  end

  it 'does not render additonal meta information if meta option is empty' do
    hash = decorator.to_hash('meta' => {})
    hash['meta']['copyright'].must_be_nil
    hash['meta']['reviewers'].must_equal(['Christian Bernstein'])
    hash['meta']['reviewer_initials'].must_equal('C.B.')
  end

  describe "Single Resource Object" do
    class DocumentSingleResourceObjectDecorator < Roar::Decorator
      include Roar::JSON::JSONAPI
      type :articles

      attributes do
        property :title
      end
    end

    let(:document) {
      %({
        "data": {
          "id": "1",
          "attributes": {
            "title": "My Article"
          },
          "type": "articles"
        }
      })
    }

    let(:collection_document) {
      %({
        "data": [
          {
            "type": "articles",
            "id": "1",
            "attributes": {
              "title": "My Article"
            }
          }
        ]
      })
    }

    it { DocumentSingleResourceObjectDecorator.new(Article.new(1, 'My Article')).to_json.must_equal_json document }
    it { DocumentSingleResourceObjectDecorator.for_collection.new([Article.new(1, 'My Article')]).to_json.must_equal_json collection_document }
  end
end
