require 'test_helper'
require 'roar/json/json_api'
require 'json'

class JsonapiRenderTest < MiniTest::Spec
  let(:article) { Article.new(1, 'Health walk', Author.new(2), Author.new('editor:1'), [Comment.new('comment:1', 'Ice and Snow'), Comment.new('comment:2', 'Red Stripe Skank')]) }
  let(:decorator) { ArticleDecorator.new(article) }

  it 'renders full document' do
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
              "peer-reviewed": false
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
        "attributes": {
          "email": null
        },
        "links": {
          "self": "http://authors/2"
        }
      }, {
        "attributes": {
          "email": null
        },
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
        "reviewer-initials": "C.B."
      }
    }))
  end

  it 'included: false suppresses compound docs' do
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
              "peer-reviewed": false
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
        "reviewer-initials": "C.B."
      }
    }))
  end

  it 'renders extra toplevel meta information if meta option supplied' do
    hash = decorator.to_hash(meta: {
                               'copyright' => 'Nick Sutterer', 'reviewers' => []
                             })
    hash['meta']['copyright'].must_equal('Nick Sutterer')
    hash['meta']['reviewers'].must_equal([])
    hash['meta']['reviewer-initials'].must_equal('C.B.')
  end

  it 'does not render extra toplevel meta information if meta option is empty' do
    hash = decorator.to_hash(meta: {})
    hash['meta']['copyright'].must_be_nil
    hash['meta']['reviewers'].must_equal(['Christian Bernstein'])
    hash['meta']['reviewer-initials'].must_equal('C.B.')
  end

  describe 'Single Resource Object with simple attributes' do
    class DocumentSingleResourceObjectDecorator < Roar::Decorator
      include Roar::JSON::JSONAPI.resource :articles

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

  describe 'Single Resource Object with complex attributes' do
    class VisualArtistDecorator < Roar::Decorator
      include Roar::JSON::JSONAPI.resource :visual_artists

      attributes do
        property :name
        collection :known_aliases
        property :movement
        collection :noteable_works
      end

      link(:self)           { "http://visual_artists/#{represented.id}" }
      link(:wikipedia_page) { "https://en.wikipedia.org/wiki/#{represented.name}" }
    end

    Painter = Struct.new(:id, :name, :known_aliases, :movement, :noteable_works)

    let(:document) {
      %({
        "data": {
          "type": "visual-artists",
          "id": "p1",
          "attributes": {
            "name": "Pablo Picasso",
            "known-aliases": [
              "Pablo Ruiz Picasso"
            ],
            "movement": "Cubism",
            "noteable-works": [
              "Kahnweiler",
              "Guernica"
            ]
          },
          "links": {
            "self": "http://visual_artists/p1",
            "wikipedia-page": "https://en.wikipedia.org/wiki/Pablo Picasso"
          }
        }
      })
    }

    let(:collection_document) {
      %({
        "data": [
          {
            "type": "visual-artists",
            "id": "p1",
            "attributes": {
              "name": "Pablo Picasso",
              "known-aliases": [
                "Pablo Ruiz Picasso"
              ],
              "movement": "Cubism",
              "noteable-works": [
                "Kahnweiler",
                "Guernica"
              ]
            },
            "links": {
              "self": "http://visual_artists/p1",
              "wikipedia-page": "https://en.wikipedia.org/wiki/Pablo Picasso"
            }
          }
        ]
      })
    }

    let(:painter) {
      Painter.new('p1', 'Pablo Picasso', ['Pablo Ruiz Picasso'], 'Cubism',
                  %w(Kahnweiler Guernica))
    }

    it { VisualArtistDecorator.new(painter).to_json.must_equal_json document }
    it { VisualArtistDecorator.for_collection.new([painter]).to_json.must_equal_json collection_document }
  end


  describe 'null/ empty attributes render correctly' do
    class ArtistDecorator < Roar::Decorator
      include Roar::JSON::JSONAPI.resource :artists

      attributes do
        property :name
        collection :known_aliases
        property :movement
        collection :noteable_works
        property :genre, render_nil: false # tests that we can override default setting
      end

      link(:self)           { "http://artists/#{represented.id}" }
    end

    Painter = Struct.new(:id, :name, :known_aliases, :movement, :noteable_works, :genre)

    let(:document) {
      %({
        "data": {
          "type": "artists",
          "id": "p1",
          "attributes": {
            "name": null,
            "known-aliases": [],
            "movement": null,
            "noteable-works": []
          },
          "links": {
            "self": "http://artists/p1"
          }
        }
      })
    }

    let(:collection_document) {
      %({
        "data": [
          {
            "type": "artists",
            "id": "p1",
            "attributes": {
              "name": null,
              "known-aliases": [],
              "movement": null,
              "noteable-works": []
            },
            "links": {
              "self": "http://artists/p1"
            }
          }
        ]
      })
    }

    let(:painter) {
      Painter.new('p1', nil, [], nil, [], nil)
    }

    it { ArtistDecorator.new(painter).to_json.must_equal_json document }
    it { ArtistDecorator.for_collection.new([painter]).to_json.must_equal_json collection_document }
  end
end
