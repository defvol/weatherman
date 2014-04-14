require 'sinatra'
require 'json'
require 'net/http'

get '/ping' do
  'pong'
end

get '/forecast' do
  begin
    url = URI(params[:url])
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http|
      http.request(req)
    }
  rescue Addressable::URI::InvalidURIError => e
    return { error: e.message }.to_json
  end

  entries = []
  regex = /FORECAST VALID (\d+\/[0-9A-Z]+) (\d+.\d+N)\s+(\d+.\d+W)/
  matches = res.body.scan(regex)
  matches.each do |match|
    entries << { id: match[0], north: match[1], west: match[2] }
  end
  entries.to_json
end

