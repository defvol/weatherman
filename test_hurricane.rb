require_relative 'test_helper'

describe "The Hurricane model" do

  def setup
    @hurricane = Hurricane.new
  end

  it "should update from hash" do
    @hurricane.update({ center: "31337" })
    assert_equal "31337", @hurricane.center
  end

  it "should not create new attributes" do
    assert_raises NoMethodError do
      @hurricane.update({ foo: "bar" })
      @hurricane.foo
    end
  end

  it "should update from a NHC forecast advisory" do
    @hurricane.update_from_forecast_advisory(fixture("al102013.fstadv.020"))
    assert_equal "23.7N 99.9W", @hurricane.center
  end

  it "should be able to convert to a hash" do
    @hurricane.center = "foo"
    hash = { center: "foo" }
    assert_equal hash, @hurricane.to_hash
  end
end

