require_relative 'test_helper'

describe "The Hurricane model" do

  def setup
    @hurricane = Hurricane.new
    setup_stub_requests
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

  it "should catch FORECAST VALID" do
    bulletin = %Q{
      FORECAST VALID 13/1800Z 19.5N  95.2W
      MAX WIND  35 KT...GUSTS  45 KT.
      34 KT... 30NE  30SE  30SW  30NW.

      FORECAST VALID 14/0600Z 19.3N  95.3W
      MAX WIND  40 KT...GUSTS  50 KT.
      34 KT... 30NE  30SE  30SW  30NW.
    }
    assert_equal 2, Hurricane.new.forecasts_from_bulletin(bulletin).length
  end

  it "should catch OUTLOOK VALID" do
    bulletin = %Q{
      OUTLOOK VALID 16/1800Z 22.0N  97.5W
      MAX WIND  50 KT...GUSTS  60 KT.
    }
    assert_equal 1, Hurricane.new.forecasts_from_bulletin(bulletin).length
  end

  it "should catch OUTLOOK VALID INLAND" do
    bulletin = %Q{
      OUTLOOK VALID 17/1800Z 23.5N 100.0W...INLAND
      MAX WIND  25 KT...GUSTS  35 KT.
    }
    assert_equal 1, Hurricane.new.forecasts_from_bulletin(bulletin).length
  end

  it "should catch FORECAST and OUTLOOK VALID" do
    bulletin = %Q{
      FORECAST VALID 15/1800Z 20.7N  95.9W
      MAX WIND  45 KT...GUSTS  55 KT.
      34 KT... 40NE  40SE  40SW  40NW.

      EXTENDED OUTLOOK. NOTE...ERRORS FOR TRACK HAVE AVERAGED NEAR 150 NM
      ON DAY 4 AND 200 NM ON DAY 5...AND FOR INTENSITY NEAR 15 KT EACH DAY

      OUTLOOK VALID 16/1800Z 22.0N  97.5W
      MAX WIND  50 KT...GUSTS  60 KT.

      OUTLOOK VALID 17/1800Z 23.5N 100.0W...INLAND
      MAX WIND  25 KT...GUSTS  35 KT.
    }
    assert_equal 3, Hurricane.new.forecasts_from_bulletin(bulletin).length
  end

  it "should not catch FORECAST without wind info" do
    bulletin = "FORECAST VALID 17/1800Z...DISSIPATED"
    assert_equal 0, Hurricane.new.forecasts_from_bulletin(bulletin).length
  end
end

