require_relative 'test_helper'
require_relative 'models/regexp'

describe "The Regexp hacks" do

  it "should return hash with named groupings" do
    expected = { leet: "31337" }
    result = /(?<leet>31337)/.to_hash("find me at port 31337")
    assert_equal expected, result
  end

  it "should return empty hash when no matches found" do
    expected = {}
    result = /(?<leet>31337)/.to_hash("find me at port 80")
    assert_equal expected, result
  end

  it "should return array of hashes with named groupings" do
    expected = { leet: "31337", noob: "8080" }
    regexps = [
      /(?<leet>31337)/,
      /(?<noob>8080)/
    ]
    result = Regexp.batch_as_hash(regexps, "find me at port 31337, not 8080")
    assert_equal expected, result
  end

end

