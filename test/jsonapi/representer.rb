Author = Struct.new(:id, :email, :name) do
  def self.find_by(options)
    AuthorNine if options[:id].to_s == '9'
  end
end
AuthorNine = Author.new(9, '9@nine.to')

Article = Struct.new(:id, :title, :author, :editor, :comments, :contributors) do
  def reviewers
    ['Christian Bernstein']
  end
end

Comment = Struct.new(:comment_id, :body) do
  def self.find_by(_options)
    new
  end
end

class AuthorDecorator < Roar::Decorator
  include Roar::JSON::JSONAPI.resource :authors

  attributes do
    property :email
  end

  link(:self) { "http://authors/#{represented.id}" }
end

class CommentDecorator < Roar::Decorator
  include Roar::JSON::JSONAPI.resource(:comments, id_key: :comment_id)

  attributes do
    property :body
  end

  link(:self) { "http://comments/#{represented.comment_id}" }
end

class ArticleDecorator < Roar::Decorator
  include Roar::JSON::JSONAPI.resource :articles

  # top-level link.
  link :self, toplevel: true do |options|
    if options
      "//articles?page=#{options[:page]}&per_page=#{options[:per_page]}"
    else
      '//articles'
    end
  end

  meta toplevel: true do
    property :count
  end

  attributes do
    property :title
  end

  meta do
    collection :reviewers
  end

  meta do
    property :reviewer_initials, getter: ->(_) {
      reviewers.map { |reviewer|
        reviewer.split.map { |name| "#{name[0]}." }.join
      }.join(', ')
    }
  end

  # resource object links
  link(:self) { "http://#{represented.class}/#{represented.id}" }

  # relationships
  has_one :author, class: Author, decorator: AuthorDecorator,
    populator: ::Representable::FindOrInstantiate do # populator is for parsing, only.
    relationship do
      link(:self)     { "/articles/#{represented.id}/relationships/author" }
      link(:related)  { "/articles/#{represented.id}/author" }
    end
  end

  has_one :editor do
    type :editors

    relationship do
      meta do
        property :peer_reviewed, getter: ->(_) { false }
      end
    end

    attributes do
      property :email
    end
    # No self link for editors because we want to make sure the :links option does not appear in the hash.
  end

  has_many :comments, class: Comment, decorator: CommentDecorator,
    populator: ::Representable::FindOrInstantiate do
    relationship do
      link(:self)     { "/articles/#{represented.id}/relationships/comments" }
      link(:related)  { "/articles/#{represented.id}/comments" }

      meta do
        property :count, as: 'comment-count'
      end
    end
  end

  # this relationship should be listed in relationships but no data included/sideloaded
  has_many :contributors, class: Author, included: false do
    type :authors

    relationship do
      link(:self)     { "/articles/#{represented.id}/relationships/contributors" }
      link(:related)  { "/articles/#{represented.id}/contributors" }
    end
  end
end
