ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)

require_relative 'api'

include Rack::Test::Methods

def app
  Sinatra::Application
end

