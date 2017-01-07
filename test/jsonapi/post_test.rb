require 'test_helper'
require 'roar/json/json_api'
require 'json'

class JsonapiPostTest < MiniTest::Spec
  describe 'Parse' do
    let(:post_article) {
      %({
        "data": {
          "type": "articles",
          "attributes": {
            "title": "Ember Hamster"
          },
          "relationships": {
            "author": {
              "data": {
                "type": "people",
                "id": "9",
                "name": "Celsito"
              }
            },
            "comments": {
              "data": [{
                "type": "comment",
                "id": "2"
              }, {
                "type": "comment",
                "id": "3"
              }]
            }
          }
        }
      })
    }

    subject { ArticleDecorator.new(Article.new(nil, nil, nil, nil, [])).from_json(post_article) }

    it do
      subject.title.must_equal 'Ember Hamster'
      subject.author.id.must_equal '9'
      subject.author.email.must_equal '9@nine.to'
      # subject.author.name.must_be_nil

      subject.comments.must_equal [Comment.new('2'), Comment.new('3')]
    end
  end

  describe 'Parse Simple' do
    let(:post_article) {
      %({
        "data": {
          "type": "articles",
          "attributes": {
            "title": "Ember Hamster"
          }
        }
      })
    }

    subject { ArticleDecorator.new(Article.new(nil, nil, nil, nil, [])).from_json(post_article) }

    it do
      subject.title.must_equal 'Ember Hamster'
    end
  end

  describe 'Parse Badly Formed Document' do
    let(:post_article) {
      %({"title":"Ember Hamster"})
    }

    subject { ArticleDecorator.new(Article.new(nil, nil, nil, nil, [])).from_json(post_article) }

    it do
      subject.title.must_be_nil
    end
  end
end
