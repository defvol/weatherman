require_relative 'test_helper'

describe "The NHC module" do

  def forecasts_found_from(advisory)
    NHC.parse_forecast_advisory(advisory)[:forecasts].length
  end

  it "should parse a forecast advisory" do
    result = NHC.parse_forecast_advisory fixture("past", "al102013.fstadv.020")
    # Sort the hash because fixtures have keys in ascending order
    result = Hash[result.sort_by { |k,v| k }]
    e = expected[:al102013_fstadv_020]
    assert_equal e, result
  end

  it "should catch FORECAST VALID" do
    advisory = %Q{
      FORECAST VALID 13/1800Z 19.5N  95.2W
      MAX WIND  35 KT...GUSTS  45 KT.
      34 KT... 30NE  30SE  30SW  30NW.

      FORECAST VALID 14/0600Z 19.3N  95.3W
      MAX WIND  40 KT...GUSTS  50 KT.
      34 KT... 30NE  30SE  30SW  30NW.
    }
    assert_equal 2, forecasts_found_from(advisory)
  end

  it "should catch FORECAST VALID INLAND" do
    advisory = %Q{
      FORECAST VALID 16/1800Z 22.5N  98.0W...INLAND
      MAX WIND  65 KT...GUSTS  80 KT.
      50 KT... 20NE  20SE   0SW   0NW.
      34 KT...100NE  90SE  20SW  20NW.

      FORECAST VALID 17/1800Z 22.0N  99.0W...INLAND
      MAX WIND  30 KT...GUSTS  40 KT.
    }
    assert_equal 2, forecasts_found_from(advisory)
  end

  it "should catch OUTLOOK VALID" do
    advisory = %Q{
      OUTLOOK VALID 16/1800Z 22.0N  97.5W
      MAX WIND  50 KT...GUSTS  60 KT.
    }
    assert_equal 1, forecasts_found_from(advisory)
  end

  it "should catch OUTLOOK VALID INLAND" do
    advisory = %Q{
      OUTLOOK VALID 17/1800Z 23.5N 100.0W...INLAND
      MAX WIND  25 KT...GUSTS  35 KT.
    }
    assert_equal 1, forecasts_found_from(advisory)
  end

  it "should catch FORECAST and OUTLOOK VALID" do
    advisory = %Q{
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
    assert_equal 3, forecasts_found_from(advisory)
  end

  it "should not catch FORECAST without wind info" do
    advisory = "FORECAST VALID 17/1800Z...DISSIPATED"
    assert_equal 0, forecasts_found_from(advisory)
  end
end

