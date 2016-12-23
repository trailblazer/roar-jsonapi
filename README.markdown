# ROAR JSON API

_Resource-Oriented Architectures in Ruby._

[![Gitter Chat](https://badges.gitter.im/trailblazer/chat.svg)](https://gitter.im/trailblazer/chat)
[![TRB Newsletter](https://img.shields.io/badge/TRB-newsletter-lightgrey.svg)](http://trailblazer.to/newsletter/)
[![Build Status](https://travis-ci.org/trailblazer/roar-jsonapi.svg?branch=master)](https://travis-ci.org/trailblazer/roar-jsonapi)
[![Gem Version](https://badge.fury.io/rb/roar-jsonapi.svg)](http://badge.fury.io/rb/roar-jsonapi)

## JSON API

Roar also supports [JSON API](http://jsonapi.org/) - yay! It can render _and_ parse singular and collection documents.

### Resource

A minimal representation can be defined as follows.

```ruby
require 'roar/json/json_api'

class SongsRepresenter < Roar::Decorator
  include Roar::JSON::JSONAPI
  type :songs

  property :id
  property :title
end
```

Properties of the represented model are defined in the root level.

### Hypermedia

You can add links to `linked` models within the resource section.

```ruby
class SongsRepresenter < Roar::Decorator
  # ...

  has_one :composer
  has_many :listeners
end
```

Global `links` can be added using the familiar `::link` method (this is still WIP as the DSL is not final).

```ruby
class SongsRepresenter < Roar::Decorator
  # ...

  link "songs.album" do
    {
      type: "album",
      href: "http://example.com/albums/{songs.album}"
    }
  end
end
```

### Compounds

To add compound models into the document, use `::compound`.

```ruby
class SongsRepresenter < Roar::Decorator
  # ...

compound do
  property :album do
    property :id
    property :title
  end

  collection :musicians do
    property :name
  end
end
```

### Meta information

Meta information can be included into rendered singular and collection documents in two ways.

You can define meta information on your collection object and then let Roar compile it.

```ruby
class SongsRepresenter < Roar::Decorator
  # ..

  meta toplevel: true do
    property :page
    property :total
  end
```

Your collection object must expose the respective methods.

```ruby
collection.page  #=> 1
collection.total #=> 12
```

This will render the `{"meta": {"page": 1, "total": 12}}` hash into the JSON-API document.

Alternatively, you can provide meta information as a hash when rendering.  Any values also defined on your object will be overriden.

```ruby
collection.to_json("meta" => {page: params["page"], total: collection.size})
```

Both methods work for singular documents too.

```ruby
class SongsRepresenter < Roar::Decorator
  # ..

  meta do
    property :label
    property :format
  end
end
```

```ruby
song.to_json("meta" => { label: 'EMI' })
```

If you need more functionality (and parsing), please let us know.

### Usage

As JSON-API per definition can represent singular models and collections you have two entry points.

```ruby
SongsRepresenter.prepare(Song.find(1)).to_json
SongsRepresenter.prepare(Song.new).from_json("..")
```

Singular models can use the representer module directly.

```ruby
SongsRepresenter.for_collection.prepare([Song.find(1), Song.find(2)]).to_json
SongsRepresenter.for_collection.prepare([Song.new, Song.new]).from_json("..")
```


Parsing currently works great with singular documents - for collections, we are still working out how to encode the application semantics. Feel free to help.

## Support

Questions? Need help? Free 1st Level Support on irc.freenode.org#roar !
We also have a [mailing list](https://groups.google.com/forum/?fromgroups#!forum/roar-talk), yiha!

## License

Roar is released under the [MIT License](http://www.opensource.org/licenses/MIT).
