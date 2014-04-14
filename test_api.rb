require_relative 'test_helper'

describe "The Weather API" do

  it "should answer a ping back" do
    get '/ping'
    assert last_response.ok?
    assert_equal "pong", last_response.body
  end

end

