require_relative 'test_helper'

describe "The Hurricane model" do

  def setup
    @hurricane = Hurricane.new
    setup_stub_requests
  end

  it "should update from hash" do
    @hurricane.update!({ center: "31337" })
    assert_equal "31337", @hurricane.center
  end

  it "should not create new attributes" do
    assert_raises NoMethodError do
      @hurricane.update!({ foo: "bar" })
      @hurricane.foo
    end
  end

  it "should build from a NHC forecast advisory" do
    url = "http://www.nhc.noaa.gov/archive/2013/al10/al102013.fstadv.020.shtml?text"
    h = Hurricane.from_url(url)
    assert_equal "23.7N 99.9W", h.center
  end

  it "should be able to convert to a hash" do
    @hurricane.center = "foo"
    hash = { center: "foo" }
    assert_equal hash, @hurricane.to_hash
  end

end

