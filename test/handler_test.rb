require 'test_helper'

class HandlerTest < ActiveSupport::TestCase

#  test "transliteration" do
#    unless RUBY_VERSION >= "1.9"
#      a = Band.new
#      a.name = "Häagen Dazs"
#      assert_equal "haagen_dazs", a.generate_handle
#    end
#  end

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
end


class Band
  include Handler
  attr_accessor :name
  handle_based_on :name
end


class Person
  include Handler
  attr_accessor :name
  handle_based_on :name, :separator => "-"
end


