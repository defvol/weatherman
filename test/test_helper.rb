ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)

require_relative '../api'

include Rack::Test::Methods

def app
  Sinatra::Application
end

def fixture(file)
  File.open("#{Dir.pwd}/fixtures/#{file}").read
end

def setup_stub_requests
  base_url = "http://www.nhc.noaa.gov/archive/2013/al10"
  Dir["fixtures/past/*"].each do |path|
    fixture = File.open(path).read
    filename = path.gsub('fixtures/past','')
    stub_request(:get, base_url + filename).
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => fixture, :headers => {})
  end

  base_url = "http://www.nhc.noaa.gov/text/refresh"
  Dir["fixtures/latest/*"].each do |path|
    fixture = File.open(path).read
    filename = path.gsub('fixtures/latest','').gsub(':','/')
    stub_request(:get, base_url + filename).
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => fixture, :headers => {})
  end

  stub_request(:get, "http://www.example.com/").
    with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => "<body>Hello world</body>", :headers => {})
end

def expected
  {
    al102013_fstadv_001: {
      center: "19.7N 93.6W",
      effective: "12/2100Z",
      forecasts: [
        { id: "13/0600Z", north: "19.7N", west: "94.7W", max: "30 KT", gusts: "40 KT" },
        { id: "13/1800Z", north: "19.5N", west: "95.2W", max: "35 KT", gusts: "45 KT" },
        { id: "14/0600Z", north: "19.3N", west: "95.3W", max: "40 KT", gusts: "50 KT" },
        { id: "14/1800Z", north: "19.3N", west: "95.0W", max: "45 KT", gusts: "55 KT" },
        { id: "15/1800Z", north: "20.7N", west: "95.9W", max: "45 KT", gusts: "55 KT" },
        { id: "16/1800Z", north: "22.0N", west: "97.5W", max: "50 KT", gusts: "60 KT" },
        { id: "17/1800Z", north: "23.5N", west: "100.0W", max: "25 KT", gusts: "35 KT" }
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
        { id: "17/1800Z", north: "22.0N", west: "99.0W", max: "30 KT", gusts: "40 KT" },
        { id: "18/1800Z", north: "21.5N", west: "99.0W", max: "20 KT", gusts: "30 KT" }
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
    },
    al102013_fstadv_020: {
      center: "23.7N 99.9W",
      effective: "17/0900Z",
      forecasts: [],
      minCentralPressure: "1008 MB",
      movement: "TOWARD THE WEST OR 270 DEGREES AT 4 KT",
      winds: {
        maxSustainedWindsWithGusts: "MAX SUSTAINED WINDS 20 KT WITH GUSTS TO 30 KT.",
        direction: [],
          seas: ""
      }
    },
    ep012014_fstadv_007: {
      center: "11.4N 109.6W",
      effective: "24/0900Z",
      forecasts: [
        { id: "24/1800Z", north: "11.7N", west: "110.3W", max: "65 KT", gusts: "80 KT" },
        { id: "25/0600Z", north: "11.9N", west: "110.9W", max: "80 KT", gusts: "100 KT" },
        { id: "25/1800Z", north: "12.2N", west: "111.3W", max: "85 KT", gusts: "105 KT" },
        { id: "26/0600Z", north: "12.7N", west: "111.6W", max: "90 KT", gusts: "110 KT" },
        { id: "27/0600Z", north: "14.0N", west: "112.0W", max: "75 KT", gusts: "90 KT" },
        { id: "28/0600Z", north: "15.5N", west: "112.0W", max: "60 KT", gusts: "75 KT" },
        { id: "29/0600Z", north: "17.5N", west: "112.0W", max: "45 KT", gusts: "55 KT" }
      ],
      minCentralPressure: "994 MB",
      movement: "TOWARD THE WEST-NORTHWEST OR 295 DEGREES AT 4 KT",
      winds: {
        maxSustainedWindsWithGusts: "MAX SUSTAINED WINDS 55 KT WITH GUSTS TO 65 KT.",
        direction: [
          "50 KT....... 20NE 0SE 0SW 20NW.",
          "34 KT....... 50NE 20SE 20SW 50NW."
        ],
        seas: "12 FT SEAS.. 90NE  90SE  60SW  60NW."
      }
    },
    ep012014_public_007: {
      location: {
        north: 11.4,
        west: 109.6
      },
      about: [
        "ABOUT 630 MI...1020 KM SW OF MANZANILLO MEXICO"
      ],
      maxSustainedWinds: "100 KM/H",
      presentMovement: "PRESENT MOVEMENT...WNW OR 295 DEGREES AT 5 MPH...7 KM/H",
      minCentralPressure: "994 MB"
    }
  }
end

