require_relative 'test_helper'
require_relative '../models/string'

describe "The String hacks" do

  it "should return array of hashes made of groups" do
    expected = [{ leet: "31337" }]
    keys = [:leet]
    result = "find me at port 31337".scan_as_hash_array(/(?<leet>31337)/, keys)
    assert_equal expected, result
  end

end

