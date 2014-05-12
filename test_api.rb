require_relative 'test_helper'

describe "The Weather API" do

  def setup
    setup_stub_requests
  end

  it "should answer a ping back" do
    get '/ping'
    assert last_response.ok?
    assert_equal last_response.body, "pong"
  end

  it "should parse Cyclone Forecasts" do
    url = "http://www.nhc.noaa.gov/archive/2013/al10/al102013.fstadv.001.shtml?text"
    get "/forecast?url=#{url}"
    assert last_response.ok?
    assert_equal expected[:al102013_fstadv_001].to_json, last_response.body
  end

  it "should support jsonp format" do
    url = "http://www.nhc.noaa.gov/archive/2013/al10/al102013.fstadv.001.shtml?text"
    get "/forecast?url=#{url}&format=jsonp&callback=foo"
    assert last_response.ok?
    response = expected[:al102013_fstadv_001].to_json
    assert_equal "foo(#{response});", last_response.body
  end

  it "should parse Public Advisories" do
    url = "http://www.nhc.noaa.gov/archive/2013/al10/al102013.public.001.shtml?text"
    get "/advisory?url=#{url}"
    assert last_response.ok?
    response = {
      location: { north: 19.7, west: 93.6 },
      about: ["ABOUT 175 MI...280 KM ENE OF VERACRUZ MEXICO"],
      maxSustainedWinds: "55 KM/H",
      presentMovement: "PRESENT MOVEMENT...W OR 270 DEGREES AT 7 MPH...11 KM/H",
      minCentralPressure: "1003 MB"
    }.to_json
    assert_equal last_response.body, response
  end

  it "should support multiple ABOUT locations" do
    url = "http://www.nhc.noaa.gov/archive/2013/al10/al102013.public.010.shtml?text"
    get "/advisory?url=#{url}"
    assert last_response.ok?
    response = {
      location: { north: 21.3, west: 94.4 },
      about: [
        "ABOUT 195 MI...315 KM E OF TUXPAN MEXICO",
        "ABOUT 275 MI...445 KM SE OF LA PESCA MEXICO"
      ],
      maxSustainedWinds: "120 KM/H",
      presentMovement: "PRESENT MOVEMENT...N OR 360 DEGREES AT 7 MPH...11 KM/H",
      minCentralPressure: "987 MB"
    }.to_json
    assert_equal last_response.body, response
  end

  it "should catch inland forecasts" do
    url = "http://www.nhc.noaa.gov/archive/2013/al10/al102013.fstadv.010.shtml?text"
    get "/forecast?url=#{url}"
    assert last_response.ok?
    response = expected[:al102013_fstadv_010].to_json
    assert_equal response, last_response.body
  end

  it "should not break with bogus urls" do
    get "/forecast?url=fubar"
    assert_match(/Invalid port number/, last_response.body)
    get "/advisory?url=fubar"
    assert_match(/Invalid port number/, last_response.body)
  end

  it "should not break with unparsable urls" do
    get "/forecast?url=http://www.example.com"
    response = {
      forecasts: [],
      winds: {
        maxSustainedWindsWithGusts: "",
        direction: [],
        seas: ""
      }
    }
    assert_equal response.to_json, last_response.body
    get "/advisory?url=http://www.example.com"
    error_message = { error: "This doesn't look like a Public Advisory" }.to_json
    assert_equal last_response.body, error_message
  end

end

