require "test_helper"
require "roar/json/json_api"
require "json"
require "jsonapi/representer"

class JsonapiCollectionRenderTest < MiniTest::Spec
  let (:article) { Article.new(1, "Health walk", Author.new(2), Author.new("editor:1"), [Comment.new("comment:1", "Ice and Snow"),Comment.new("comment:2", "Red Stripe Skank")])}
  let (:article2) { Article.new(2, "Virgin Ska", Author.new("author:1"), nil, [Comment.new("comment:3", "Cool song!")]) }
  let (:article3) { Article.new(3, "Gramo echo", Author.new("author:1"), nil, [Comment.new("comment:4", "Skalar")]) }
  let (:decorator) { ArticleDecorator.for_collection.new([article, article2, article3]) }

  it "renders full document" do
    hash = decorator.to_hash
    hash.must_equal('data'     => [
                      {
                        'type'          => 'articles',
                        'id'            => '1',
                        'attributes'    => { 'title' => 'Health walk' },
                        'relationships' => {
                          'author'   => {
                            'data'  => { 'type' => 'authors', 'id' => '2' },
                            'links' => {
                              'self'    => '/articles/1/relationships/author',
                              'related' => '/articles/1/author'
                            }
                          },
                          'editor'   => {
                            'data' => { 'type' => 'editors', 'id' => 'editor:1' },
                            'meta' => { 'peer_reviewed' => false }
                          },
                          'comments' => {
                            'data'  => [
                              { 'type' => 'comments', 'id' => 'comment:1' },
                              { 'type' => 'comments', 'id' => 'comment:2' }
                            ],
                            'links' => {
                              'self'    => '/articles/1/relationships/comments',
                              'related' => '/articles/1/comments'
                            },
                            'meta' => { 'comment-count' => 5 }
                          }
                        },
                        'links'         => { 'self' => 'http://Article/1' }
                      },
                      {
                        'type'          => 'articles',
                        'id'            => '2',
                        'attributes'    => { 'title' => 'Virgin Ska' },
                        'relationships' => {
                          'author'   => {
                            'data'  => { 'type' => 'authors', 'id' => 'author:1' },
                            'links' => {
                              'self'    => '/articles/2/relationships/author',
                              'related' => '/articles/2/author'
                            }
                          },
                          'comments' => {
                            'data'  => [
                              { 'type' => 'comments', 'id' => 'comment:3' }
                            ],
                            'links' => {
                              'self'    => '/articles/2/relationships/comments',
                              'related' => '/articles/2/comments'
                            },
                            'meta' => { 'comment-count' => 5 }
                          }
                        },
                        'links'         => { 'self' => 'http://Article/2' }
                      },
                      {
                        'type'          => 'articles',
                        'id'            => '3',
                        'attributes'    => { 'title' => 'Gramo echo' },
                        'relationships' => {
                          'author'   => {
                            'data'  => { 'type' => 'authors', 'id' => 'author:1' },
                            'links' => {
                              'self'    => '/articles/3/relationships/author',
                              'related' => '/articles/3/author'
                            }
                          },
                          'comments' => {
                            'data'  => [
                              { 'type' => 'comments', 'id' => 'comment:4' }
                            ],
                            'links' => {
                              'self'    => '/articles/3/relationships/comments',
                              'related' => '/articles/3/comments'
                            },
                            'meta' => { 'comment-count' => 5 }
                          }
                        },
                        'links'         => { 'self' => 'http://Article/3' }
                      }
                    ],
                    'links'    => { 'self' => '//articles' },
                    'meta'     => { 'count' => 3 },
                    'included' => [
                      {
                        'type'  => 'authors',
                        'id'    => '2',
                        'links' => { 'self' => 'http://authors/2' }
                      },
                      {
                        'type' => 'editors',
                        'id'   => 'editor:1'
                      },
                      {
                        'type'       => 'comments',
                        'id'         => 'comment:1',
                        'attributes' => { 'body' => 'Ice and Snow' },
                        'links'      => { 'self' => 'http://comments/comment:1' }
                      },
                      {
                        'type'       => 'comments',
                        'id'         => 'comment:2',
                        'attributes' => { 'body' => 'Red Stripe Skank' },
                        'links'      => { 'self' => 'http://comments/comment:2' }
                      },
                      {
                        'type'  => 'authors',
                        'id'    => 'author:1',
                        'links' => { 'self' => 'http://authors/author:1' }
                      },
                      {
                        'type'       => 'comments',
                        'id'         => 'comment:3',
                        'attributes' => { 'body' => 'Cool song!' },
                        'links'      => { 'self' => 'http://comments/comment:3' }
                      },
                      {
                        'type'       => 'comments',
                        'id'         => 'comment:4',
                        'attributes' => { 'body' => 'Skalar' },
                        'links'      => { 'self' => 'http://comments/comment:4' }
                      }
                    ])
  end

  it "included: false suppresses compound docs" do
    hash = decorator.to_hash(included: false)
    hash.must_equal('data'  => [
                      {
                        'type'          => 'articles',
                        'id'            => '1',
                        'attributes'    => { 'title' => 'Health walk' },
                        'relationships' => {
                          'author'   => {
                            'data'  => { 'type' => 'authors', 'id' => '2' },
                            'links' => {
                              'self'    => '/articles/1/relationships/author',
                              'related' => '/articles/1/author'
                            }
                          },
                          'editor'   => {
                            'data' => { 'type' => 'editors', 'id' => 'editor:1' },
                            'meta' => { 'peer_reviewed' => false }
                          },
                          'comments' => {
                            'data'  => [
                              { 'type' => 'comments', 'id' => 'comment:1' },
                              { 'type' => 'comments', 'id' => 'comment:2' }
                            ],
                            'links' => {
                              'self'    => '/articles/1/relationships/comments',
                              'related' => '/articles/1/comments'
                            },
                            'meta' => { 'comment-count' => 5 }
                          }
                        },
                        'links'         => { 'self' => 'http://Article/1' }
                      },
                      {
                        'type'          => 'articles',
                        'id'            => '2',
                        'attributes'    => { 'title' => 'Virgin Ska' },
                        'relationships' => {
                          'author'   => {
                            'data'  => { 'type' => 'authors', 'id' => 'author:1' },
                            'links' => {
                              'self'    => '/articles/2/relationships/author',
                              'related' => '/articles/2/author'
                            }
                          },
                          'comments' => {
                            'data'  => [
                              { 'type' => 'comments', 'id' => 'comment:3' }
                            ],
                            'links' => {
                              'self'    => '/articles/2/relationships/comments',
                              'related' => '/articles/2/comments'
                            },
                            'meta' => { 'comment-count' => 5 }
                          }
                        },
                        'links'         => { 'self' => 'http://Article/2' }
                      },
                      {
                        'type'          => 'articles',
                        'id'            => '3',
                        'attributes'    => { 'title' => 'Gramo echo' },
                        'relationships' => {
                          'author'   => {
                            'data'  => { 'type' => 'authors', 'id' => 'author:1' },
                            'links' => {
                              'self'    => '/articles/3/relationships/author',
                              'related' => '/articles/3/author'
                            }
                          },
                          'comments' => {
                            'data'  => [
                              { 'type' => 'comments', 'id' => 'comment:4' }
                            ],
                            'links' => {
                              'self'    => '/articles/3/relationships/comments',
                              'related' => '/articles/3/comments'
                            },
                            'meta' => { 'comment-count' => 5 }
                          }
                        },
                        'links'         => { 'self' => 'http://Article/3' }
                      }
                    ],
                    'links' => { 'self' => '//articles' },
                    'meta'  => { 'count' => 3 })
  end

  it "passes :user_options to toplevel links when rendering" do
    hash = decorator.to_hash(user_options: { page: 2, per_page: 10 })
    hash['links'].must_equal({
      "self" => "//articles?page=2&per_page=10"
    })
  end

  it 'renders additional meta information if meta option supplied' do
    hash = decorator.to_hash('meta' => { page: 2, total: 9 })
    hash['meta'].must_equal("count" => 3, page: 2, total: 9)
  end

  it 'does not render additional meta information if meta option is empty' do
    hash = decorator.to_hash('meta' => {})
    hash['meta'][:page].must_be_nil
    hash['meta'][:total].must_be_nil
  end

  describe "Fetching Resources (empty collection)" do
    let(:document) {
      {
        "data" => [],
        "links" => {
          "self" => "//articles"
        },
        "meta" => {
          "count" => 0
        }
      }
    }

    let(:articles) { [] }
    subject { ArticleDecorator.for_collection.new(articles).to_json }

    it { subject.must_equal document.to_json }
  end
end
