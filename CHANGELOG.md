# 0.0.4
* add as option to has_one and has_many declarations to allow custom names (@gerardo-navarro)
* add included option to relationships to stop including data in compound document (@franworley)
* fixes `extend:` and `decorates:` options to behave identically (@myabc/@KonstantinKo)
* include null attributes in resource documents by default (@franworley)
* Ensure meta: option only renders at top-level (@myabc)

# 0.0.3
* Make `Document` module part of public API. This allows other libraries to hook
ing into the parsing/rendering of all JSON API documents, whether their data
contains a single Resource Object or a collection of Resource Objects. (@myabc)

# 0.0.2

* Require Representable 3.0.3, which replaces `Uber::Option` with the new [`Declarative::Option`](https://github.com/apotonick/declarative-option). (@myabc)

# 0.0.1

Initial release as a standalone gem.
