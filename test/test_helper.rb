# Incorporate test coverage info generated by CI into Code climate
if ENV['CI']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

require 'webmock/minitest'
WebMock.disable_net_connect!(
  :allow_localhost => true,
  :allow => "codeclimate.com")

require_relative '../api'
require_relative '../models/hash'

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
    make_stub_request(url: base_url + filename, response: fixture)
  end

  # Stubbing manually; using base_url + filename didn't work
  make_stub_request({
    url: "http://www.nhc.noaa.gov/text/refresh/MIATCPEP1+shtml/232030.shtml",
    response: fixture("latest/MIATCPEP1+shtml:240833.shtml?")
  })
  make_stub_request({
    url: "http://www.nhc.noaa.gov/text/refresh/MIATCMEP1+shtml/232030.shtml",
    response: fixture("latest/MIATCMEP1+shtml:240833.shtml?"),
  })

  make_stub_request({
    url: "http://www.example.com/",
    response: "<body>Hello world</body>"
  })
end

def make_stub_request(params)
  stub_request(:get, params[:url]).
    with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => params[:response], :headers => {})
end

