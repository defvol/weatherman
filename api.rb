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
  regex = /FORECAST VALID (\d+\/\w+) (\d+.\d+N)\s+(\d+.\d+W)\s+MAX WIND\s+(\d+ KT).+GUSTS\s+(\d+ KT)/
  matches = res.body.scan(regex)
  matches.each do |match|
    entries << { id: match[0], north: match[1], west: match[2], max: match[3], gusts: match[4] }
  end
  entries.to_json
end

