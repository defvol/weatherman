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
  end

  it "should answer a ping back" do
    get '/ping'
    assert last_response.ok?
    assert_equal "pong", last_response.body
  end

  it "should parse Cyclone Forecasts" do
    url = "http://www.nhc.noaa.gov/archive/2013/al10/al102013.fstadv.001.shtml?text"
    get "/forecast?url=#{url}"
    assert last_response.ok?
    response = [
      { id: "13/0600Z", north: "19.7N", west: "94.7W", max: "30 KT", gusts: "40 KT" },
      { id: "13/1800Z", north: "19.5N", west: "95.2W", max: "35 KT", gusts: "45 KT" },
      { id: "14/0600Z", north: "19.3N", west: "95.3W", max: "40 KT", gusts: "50 KT" },
      { id: "14/1800Z", north: "19.3N", west: "95.0W", max: "45 KT", gusts: "55 KT" },
      { id: "15/1800Z", north: "20.7N", west: "95.9W", max: "45 KT", gusts: "55 KT" }
    ].to_json
    assert_equal response, last_response.body
  end

  it "should support jsonp format" do
    url = "http://www.nhc.noaa.gov/archive/2013/al10/al102013.fstadv.010.shtml?text"
    get "/forecast?url=#{url}&format=jsonp&callback=foo"
    assert last_response.ok?
    response = [
      { id: "15/0600Z", north: "22.0N", west: "94.5W", max: "70 KT", gusts: "85 KT" },
      { id: "15/1800Z", north: "22.7N", west: "95.4W", max: "75 KT", gusts: "90 KT" },
      { id: "16/0600Z", north: "22.8N", west: "97.0W", max: "75 KT", gusts: "90 KT" },
      { id: "16/1800Z", north: "22.5N", west: "98.0W", max: "65 KT", gusts: "80 KT" },
      { id: "17/1800Z", north: "22.0N", west: "99.0W", max: "30 KT", gusts: "40 KT" }
    ].to_json
    assert_equal "foo(#{response});", last_response.body
  end

  it "should not break with bogus urls" do
    get "/forecast?url=fubar"
    assert_match(/Invalid port number/, last_response.body)
  end

  it "should not break with unparsable urls" do
    get "/forecast?url=http://www.example.com"
    assert_equal "[]", last_response.body
  end

end

