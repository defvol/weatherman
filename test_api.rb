require_relative 'test_helper'

describe "The Weather API" do

  def setup
    nhc_url = "http://www.nhc.noaa.gov/archive/2013/al10/"
    Dir["fixtures/*"].each do |path|
      fixture = File.open(path).read
      filename = path.gsub('fixtures/','')
      stub_request(:get, nhc_url + filename).
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => fixture, :headers => {})
    end

    stub_request(:get, "http://www.example.com/").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "<body>Hello world</body>", :headers => {})

    @expected = {
      al102013_fstadv_001: {
        center: "19.7N 93.6W",
        effective: "12/2100Z",
        forecasts: [
          { id: "13/0600Z", north: "19.7N", west: "94.7W", max: "30 KT", gusts: "40 KT" },
          { id: "13/1800Z", north: "19.5N", west: "95.2W", max: "35 KT", gusts: "45 KT" },
          { id: "14/0600Z", north: "19.3N", west: "95.3W", max: "40 KT", gusts: "50 KT" },
          { id: "14/1800Z", north: "19.3N", west: "95.0W", max: "45 KT", gusts: "55 KT" },
          { id: "15/1800Z", north: "20.7N", west: "95.9W", max: "45 KT", gusts: "55 KT" }
        ],
        minCentralPressure: "1003 MB",
        movement: "TOWARD THE WEST OR 270 DEGREES AT 6 KT",
        winds: {
          maxSustainedWindsWithGusts: "MAX SUSTAINED WINDS 30 KT WITH GUSTS TO 40 KT.",
          direction: [],
          seas: ""
        }
      },
      al102013_fstadv_010: {
        center: "21.3N 94.4W",
        effective: "14/2100Z",
        forecasts: [
          { id: "15/0600Z", north: "22.0N", west: "94.5W", max: "70 KT", gusts: "85 KT" },
          { id: "15/1800Z", north: "22.7N", west: "95.4W", max: "75 KT", gusts: "90 KT" },
          { id: "16/0600Z", north: "22.8N", west: "97.0W", max: "75 KT", gusts: "90 KT" },
          { id: "16/1800Z", north: "22.5N", west: "98.0W", max: "65 KT", gusts: "80 KT" },
          { id: "17/1800Z", north: "22.0N", west: "99.0W", max: "30 KT", gusts: "40 KT" }
        ],
        minCentralPressure: "987 MB",
        movement: "TOWARD THE NORTH OR 360 DEGREES AT 6 KT",
        winds: {
          maxSustainedWindsWithGusts: "MAX SUSTAINED WINDS 65 KT WITH GUSTS TO 80 KT.",
          direction: [
            "64 KT....... 20NE 0SE 0SW 0NW",
            "50 KT....... 40NE 20SE 0SW 20NW",
            "34 KT....... 70NE 60SE 40SW 40NW"
          ],
          seas: "12 FT SEAS..150NE 90SE 60SW 120NW."
        }
      }
    }
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
    assert_equal @expected[:al102013_fstadv_001].to_json, last_response.body
  end

  it "should support jsonp format" do
    url = "http://www.nhc.noaa.gov/archive/2013/al10/al102013.fstadv.001.shtml?text"
    get "/forecast?url=#{url}&format=jsonp&callback=foo"
    assert last_response.ok?
    response = @expected[:al102013_fstadv_001].to_json
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
    response = @expected[:al102013_fstadv_010].to_json
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

