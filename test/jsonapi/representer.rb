Author = Struct.new(:id, :email, :name) do
  def self.find_by(options)
    AuthorNine if options[:id].to_s=="9"
  end
end
AuthorNine = Author.new(9, "9@nine.to")

Article = Struct.new(:id, :title, :author, :editor, :comments) do
  def reviewers
    ['Christian Bernstein']
  end
end

Comment = Struct.new(:id, :body) do
  def self.find_by(options)
    new
  end
end

class AuthorDecorator < Roar::Decorator
  include Roar::JSON::JSONAPI
  type :authors

  relationship do
    link(:self)     { "/articles/#{represented.id}/relationships/author" }
    link(:related)  { "/articles/#{represented.id}/author" }
  end

  attributes do
    property :email
  end

  link(:self) { "http://authors/#{represented.id}" }
end

class CommentDecorator < Roar::Decorator
  include Roar::JSON::JSONAPI
  type :comments

  relationship do
    link(:self)     { "/articles/#{represented.id}/relationships/comments" }
    link(:related)  { "/articles/#{represented.id}/comments" }

    meta do
      property :count, as: 'comment-count'
    end
  end

  attributes do
    property :body
  end

  link(:self) { "http://comments/#{represented.id}" }
end

class ArticleDecorator < Roar::Decorator
  include Roar::JSON::JSONAPI
  type :articles

  # top-level link.
  link :self, toplevel: true do |options|
    if options
      "//articles?page=#{options[:page]}&per_page=#{options[:per_page]}"
    else
      "//articles"
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
      reviewers.map {|reviewer|
        reviewer.split.map { |name| "#{name[0]}." }.join
      }.join(', ')
    }
  end

  # resource object links
  link(:self) { "http://#{represented.class}/#{represented.id}" }

  # relationships
  has_one :author, class: Author, decorator: AuthorDecorator,
    populator: ::Representable::FindOrInstantiate # populator is for parsing, only.

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
    populator: ::Representable::FindOrInstantiate
end
