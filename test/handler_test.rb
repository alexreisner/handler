require 'test_helper'

class HandlerTest < ActiveSupport::TestCase

  test "transliteration" do
    a = Band.new
    a.name = "Häagen Dazs"
    possibilities = [
      "haagen_dazs", # output of unidecode or normalization
      "hagen_dazs",  # output of iconv
    ]
    assert possibilities.include?(a.generate_handle)
  end

  test "custom separator" do
    a = Person.new
    a.name = "Muddy Waters"
    assert_equal "muddy-waters", a.generate_handle
  end

  test "punctuation replacement" do
    b = Band.new
    {
      ".38 Special"                 => "38_special",
      "Guns N' Roses"               => "guns_n_roses",
      "The Rossington-Collins Band" => "the_rossington_collins_band"

    }.each do |s,t|
      b.name = s
      assert_equal t, b.generate_handle
    end
  end

  test "ampersand replacement" do
    b = Band.new
    {
      "Y&T"                    => "y_and_t",
      "Huey Lewis & the News"  => "huey_lewis_and_the_news",
      "Emerson, Lake & Palmer" => "emerson_lake_and_palmer"

    }.each do |s,t|
      b.name = s
      assert_equal t, b.generate_handle
    end
  end

  test "next handle" do
    assert_equal "banana_boat_2",  Handler.next_handle("banana_boat",    "_")
    assert_equal "banana-boat-3",  Handler.next_handle("banana-boat-2",  "-")
    assert_equal "banana-boat-12", Handler.next_handle("banana-boat-11", "-")
  end

  test "unique handle generation" do
    p = Person.new
    p.name = "Captain Beefheart"
    assert_equal "captain-beefheart-2", p.generate_handle
    p.name = "Abe Lincoln"
    assert_equal "abe-lincoln-4", p.generate_handle
  end
end

class ActiveRecordSimulator
  include Handler
  attr_accessor :name

  # simulate id method
  def id; 123; end

  # simulate new_record? method
  def new_record?; true; end

  # simulate ActiveRecord::Base.where method;
  # needed for testing whether records exist with a given handle
  def self.where(options)
    @existing_handles.include?(options[1]) ? [nil, nil] : []
  end
end

class Band < ActiveRecordSimulator
  handle_based_on :name
  @existing_handles = [
    "the_residents",
    "bing_crosby"
  ]
end

class Person < ActiveRecordSimulator
  handle_based_on :name, :separator => "-"
  @existing_handles = [
    "van-dyke-parks",
    "captain-beefheart",
    "abe-lincoln",
    "abe-lincoln-2",
    "abe-lincoln-3"
  ]
end

