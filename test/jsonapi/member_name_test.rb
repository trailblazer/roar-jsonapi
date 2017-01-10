# encoding: utf-8

require 'test_helper'
require 'roar/json/json_api'
require 'json'
require 'jsonapi/representer'

class MemberNameTest < MiniTest::Spec
  MemberName = Roar::JSON::JSONAPI::MemberName

  # http://jsonapi.org/format/#document-member-names-reserved-characters
  UNICODE_RESERVED_CHARACTERS = [
    "\u002B",
    "\u002C",
    "\u002E",
    "\u005B",
    "\u005D",
    "\u0021",
    "\u0022",
    "\u0023",
    "\u0024",
    "\u0025",
    "\u0026",
    "\u0027",
    "\u0028",
    "\u0029",
    "\u002A",
    "\u002F",
    "\u003A",
    "\u003B",
    "\u003C",
    "\u003D",
    "\u003E",
    "\u003F",
    "\u0040",
    "\u005C",
    "\u005E",
    "\u0060",
    "\u007B",
    "\u007C",
    "\u007D",
    "\u007E"
  ].freeze

  describe 'strict (default)' do
    it 'permits alphanumeric ASCII characters, hyphens' do
      MemberName.('99 Luftballons').must_equal '99luftballons'
      MemberName.('Artist').must_equal 'artist'
      MemberName.('Актер').must_equal ''
      MemberName.('おまかせ').must_equal ''
      MemberName.('auf-der-bühne').must_equal 'auf-der-bhne'
      MemberName.('nouvelle_interprétation').must_equal 'nouvelle-interprtation'
    end

    it 'does not permit any reserved characters' do
      MemberName.(UNICODE_RESERVED_CHARACTERS.join).must_equal ''
    end

    it 'hyphenates underscored words' do
      MemberName.('playtime_report').must_equal 'playtime-report'
    end
  end

  describe 'non-strict' do
    it 'permits alphanumeric unicode characters, hyphens, underscores and spaces' do
      MemberName.('99 Luftballons', strict: false).must_equal '99 Luftballons'
      MemberName.('Artist', strict: false).must_equal 'Artist'
      MemberName.('Актер', strict: false).must_equal 'Актер'
      MemberName.('おまかせ', strict: false).must_equal 'おまかせ'
      MemberName.('auf-der-bühne', strict: false).must_equal 'auf-der-bühne'
      MemberName.('nouvelle_interprétation', strict: false).must_equal 'nouvelle_interprétation'
    end

    it 'does not permit any reserved characters' do
      MemberName.(UNICODE_RESERVED_CHARACTERS.join, strict: false).must_equal ''
    end

    it 'does not permit hyphens, underscores or spaces at beginning or end' do
      MemberName.(' 99 Luftballons ', strict: false).must_equal '99 Luftballons'
      MemberName.('-Artist_', strict: false).must_equal 'Artist'
      MemberName.('_Актер', strict: false).must_equal 'Актер'
      MemberName.(' おまかせ', strict: false).must_equal 'おまかせ'
      MemberName.('-auf-der-bühne', strict: false).must_equal 'auf-der-bühne'
      MemberName.('nouvelle_interprétation_', strict: false).must_equal 'nouvelle_interprétation'
    end

    it 'preserves underscored words' do
      MemberName.('playtime_report', strict: false).must_equal 'playtime_report'
    end
  end
end
