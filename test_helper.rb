ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

require_relative 'api'

include Rack::Test::Methods

def app
  Sinatra::Application
end

