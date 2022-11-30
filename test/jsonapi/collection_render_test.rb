require 'test_helper'
require 'roar/json/json_api'
require 'json'

class JsonapiCollectionRenderTest < MiniTest::Spec
  let(:article) do
    Article.new(
      1,
      'Health walk',
      Author.new(2, 'someone@author.com'),
      Author.new('editor:1'),
      [Comment.new('comment:1', 'Ice and Snow'), Comment.new('comment:2', 'Red Stripe Skank')],
      [Author.new('contributor:1'), Author.new('contributor:2')]
    )
  end

  let(:article2) do
    Article.new(
      2,
      'Virgin Ska',
      Author.new('author:1'),
      nil,
      [Comment.new('comment:3', 'Cool song!')],
      [Author.new('contributor:1'), Author.new('contributor:2')]
    )
  end

  let(:article3) do
    Article.new(
      3,
      'Gramo echo',
      Author.new('author:1'),
      nil,
      [Comment.new('comment:4', 'Skalar')],
      [Author.new('contributor:1'), Author.new('contributor:2')]
    )
  end

  let(:decorator) { ArticleDecorator.for_collection.new([article, article2, article3]) }

  it 'renders full document' do
    json = decorator.to_json
    json.must_equal_json(%({
      "data": [{
        "type": "articles",
        "id": "1",
        "attributes": {
          "title": "Health walk"
        },
        "relationships": {
          "author": {
            "data": {
              "type": "authors",
              "id": "2"
            },
            "links": {
              "self": "/articles/1/relationships/author",
              "related": "/articles/1/author"
            }
          },
          "editor": {
            "data": {
              "type": "editors",
              "id": "editor:1"
            },
            "meta": {
              "peer-reviewed": false
            }
          },
          "comments": {
            "data": [{
              "type": "comments",
              "id": "comment:1"
            }, {
              "type": "comments",
              "id": "comment:2"
            }],
            "links": {
              "self": "/articles/1/relationships/comments",
              "related": "/articles/1/comments"
            },
            "meta": {
              "comment-count": 6
            }
          },
          "contributors": {
            "data": [{
              "id": "contributor:1",
              "type": "authors"
            }, {
              "id": "contributor:2",
              "type": "authors"
            }],
            "links": {
              "self": "/articles/1/relationships/contributors",
              "related": "/articles/1/contributors"
            }
          }
        },
        "links": {
          "self": "http://Article/1"
        },
        "meta": {
          "reviewers": ["Christian Bernstein"],
          "reviewer-initials": "C.B."
        }
      }, {
        "type": "articles",
        "id": "2",
        "attributes": {
          "title": "Virgin Ska"
        },
        "relationships": {
          "author": {
            "data": {
              "type": "authors",
              "id": "author:1"
            },
            "links": {
              "self": "/articles/2/relationships/author",
              "related": "/articles/2/author"
            }
          },
          "editor": {
            "data": null,
            "meta": {
              "peer-reviewed": false
            }
          },
          "comments": {
            "data": [{
              "type": "comments",
              "id": "comment:3"
            }],
            "links": {
              "self": "/articles/2/relationships/comments",
              "related": "/articles/2/comments"
            },
            "meta": {
              "comment-count": 6
            }
          },
          "contributors": {
            "data": [{
              "id": "contributor:1",
              "type": "authors"
            }, {
              "id": "contributor:2",
              "type": "authors"
            }],
            "links": {
              "self": "/articles/2/relationships/contributors",
              "related": "/articles/2/contributors"
            }
          }
        },
        "links": {
          "self": "http://Article/2"
        },
        "meta": {
          "reviewers": ["Christian Bernstein"],
          "reviewer-initials": "C.B."
        }
      }, {
        "type": "articles",
        "id": "3",
        "attributes": {
          "title": "Gramo echo"
        },
        "relationships": {
          "author": {
            "data": {
              "type": "authors",
              "id": "author:1"
            },
            "links": {
              "self": "/articles/3/relationships/author",
              "related": "/articles/3/author"
            }
          },
          "editor": {
            "data": null,
            "meta": {
              "peer-reviewed": false
            }
          },
          "comments": {
            "data": [{
              "type": "comments",
              "id": "comment:4"
            }],
            "links": {
              "self": "/articles/3/relationships/comments",
              "related": "/articles/3/comments"
            },
            "meta": {
              "comment-count": 6
            }
          },
          "contributors": {
            "data": [{
              "id": "contributor:1",
              "type": "authors"
            }, {
              "id": "contributor:2",
              "type": "authors"
            }],
            "links": {
              "self": "/articles/3/relationships/contributors",
              "related": "/articles/3/contributors"
            }
          }
        },
        "links": {
          "self": "http://Article/3"
        },
        "meta": {
          "reviewers": ["Christian Bernstein"],
          "reviewer-initials": "C.B."
        }
      }],
      "links": {
        "self": "//articles"
      },
      "meta": {
        "count": 3
      },
      "included": [{
        "type": "authors",
        "attributes": {
          "email": "someone@author.com"
        },
        "id": "2",
        "links": {
          "self": "http://authors/2"
        }
      }, {
        "attributes": {
          "email": null
        },
        "type": "editors",
        "id": "editor:1"
      }, {
        "type": "comments",
        "id": "comment:1",
        "attributes": {
          "body": "Ice and Snow"
        },
        "links": {
          "self": "http://comments/comment:1"
        }
      }, {
        "type": "comments",
        "id": "comment:2",
        "attributes": {
          "body": "Red Stripe Skank"
        },
        "links": {
          "self": "http://comments/comment:2"
        }
      }, {
        "attributes": {
          "email": null
        },
        "type": "authors",
        "id": "author:1",
        "links": {
          "self": "http://authors/author:1"
        }
      }, {
        "type": "comments",
        "id": "comment:3",
        "attributes": {
          "body": "Cool song!"
        },
        "links": {
          "self": "http://comments/comment:3"
        }
      }, {
        "type": "comments",
        "id": "comment:4",
        "attributes": {
          "body": "Skalar"
        },
        "links": {
          "self": "http://comments/comment:4"
        }
      }]
    }))
  end

  it 'included: false suppresses compound docs' do
    json = decorator.to_json(included: false)
    json.must_equal_json(%({
      "data": [{
        "type": "articles",
        "id": "1",
        "attributes": {
          "title": "Health walk"
        },
        "relationships": {
          "author": {
            "data": {
              "type": "authors",
              "id": "2"
            },
            "links": {
              "self": "/articles/1/relationships/author",
              "related": "/articles/1/author"
            }
          },
          "editor": {
            "data": {
              "type": "editors",
              "id": "editor:1"
            },
            "meta": {
              "peer-reviewed": false
            }
          },
          "comments": {
            "data": [{
              "type": "comments",
              "id": "comment:1"
            }, {
              "type": "comments",
              "id": "comment:2"
            }],
            "links": {
              "self": "/articles/1/relationships/comments",
              "related": "/articles/1/comments"
            },
            "meta": {
              "comment-count": 6
            }
          },
          "contributors": {
            "data": [{
              "id": "contributor:1",
              "type": "authors"
            }, {
              "id": "contributor:2",
              "type": "authors"
            }],
            "links": {
              "self": "/articles/1/relationships/contributors",
              "related": "/articles/1/contributors"
            }
          }
        },
        "links": {
          "self": "http://Article/1"
        },
        "meta": {
          "reviewers": ["Christian Bernstein"],
          "reviewer-initials": "C.B."
        }
      }, {
        "type": "articles",
        "id": "2",
        "attributes": {
          "title": "Virgin Ska"
        },
        "relationships": {
          "author": {
            "data": {
              "type": "authors",
              "id": "author:1"
            },
            "links": {
              "self": "/articles/2/relationships/author",
              "related": "/articles/2/author"
            }
          },
          "editor": {
            "data": null,
            "meta": {
              "peer-reviewed": false
            }
          },
          "comments": {
            "data": [{
              "type": "comments",
              "id": "comment:3"
            }],
            "links": {
              "self": "/articles/2/relationships/comments",
              "related": "/articles/2/comments"
            },
            "meta": {
              "comment-count": 6
            }
          },
          "contributors": {
            "data": [{
              "id": "contributor:1",
              "type": "authors"
            }, {
              "id": "contributor:2",
              "type": "authors"
            }],
            "links": {
              "self": "/articles/2/relationships/contributors",
              "related": "/articles/2/contributors"
            }
          }
        },
        "links": {
          "self": "http://Article/2"
        },
        "meta": {
          "reviewers": ["Christian Bernstein"],
          "reviewer-initials": "C.B."
        }
      }, {
        "type": "articles",
        "id": "3",
        "attributes": {
          "title": "Gramo echo"
        },
        "relationships": {
          "author": {
            "data": {
              "type": "authors",
              "id": "author:1"
            },
            "links": {
              "self": "/articles/3/relationships/author",
              "related": "/articles/3/author"
            }
          },
          "editor": {
            "data": null,
            "meta": {
              "peer-reviewed": false
            }
          },
          "comments": {
            "data": [{
              "type": "comments",
              "id": "comment:4"
            }],
            "links": {
              "self": "/articles/3/relationships/comments",
              "related": "/articles/3/comments"
            },
            "meta": {
              "comment-count": 6
            }
          },
          "contributors": {
            "data": [{
              "id": "contributor:1",
              "type": "authors"
            }, {
              "id": "contributor:2",
              "type": "authors"
            }],
            "links": {
              "self": "/articles/3/relationships/contributors",
              "related": "/articles/3/contributors"
            }
          }
        },
        "links": {
          "self": "http://Article/3"
        },
        "meta": {
          "reviewers": ["Christian Bernstein"],
          "reviewer-initials": "C.B."
        }
      }],
      "links": {
        "self": "//articles"
      },
      "meta": {
        "count": 3
      }
    }))
  end

  it 'passes :user_options to toplevel links when rendering' do
    hash = decorator.to_hash(user_options: { page: 2, per_page: 10 })
    hash['links'].must_equal('self' => '//articles?page=2&per_page=10')
  end

  it 'renders extra toplevel meta information if meta option supplied' do
    hash = decorator.to_hash(meta: { page: 2, total: 9 })
    hash['meta'].must_equal('count' => 3, page: 2, total: 9)
  end

  it 'does not render extra meta information on resource objects' do
    hash = decorator.to_hash(meta: { page: 2, total: 9 })
    refute hash['data'].first['meta'].key?(:page)
    refute hash['data'].first['meta'].key?(:total)
  end

  it 'does not render extra toplevel meta information if meta option is empty' do
    hash = decorator.to_hash(meta: {})
    hash['meta'][:page].must_be_nil
    hash['meta'][:total].must_be_nil
  end

  describe 'Fetching Resources (empty collection)' do
    let(:document) {
      %({
        "data": [],
        "links": {
          "self": "//articles"
        },
        "meta": {
          "count": 0
        }
      })
    }

    let(:articles) { [] }
    subject { ArticleDecorator.for_collection.new(articles).to_json }

    it { subject.must_equal_json document }
  end
end
