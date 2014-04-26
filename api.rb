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
  regex = /FORECAST VALID (\d+\/\w+) (\d+.\d+N)\s+(\d+.\d+W).*\s+MAX WIND\s+(\d+ KT).+GUSTS\s+(\d+ KT)/
  matches = res.body.scan(regex)
  matches.each do |match|
    entries << { id: match[0], north: match[1], west: match[2], max: match[3], gusts: match[4] }
  end

  if params[:format] == 'jsonp'
    "#{ params[:callback] || 'callback' }(#{ entries.to_json });"
  else
    entries.to_json
  end
end

get '/advisory' do
  begin
    url = URI(params[:url])
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http|
      http.request(req)
    }
  rescue Addressable::URI::InvalidURIError => e
    return { error: e.message }.to_json
  end

  entry = {}

  # Return empty if unparsable
  error_message = "This doesn't look like a Public Advisory"
  return { error: error_message }.to_json if res.body.scan(/ADVISORY NUMBER\s+\d+/).empty?

  res.body.scan(/LOCATION\.{3}(.+)/).each do |m|
    entry['location'] = location_to_hash(m[0])
  end

  entry['about'] = []
  res.body.scan(/(^ABOUT \d.+)/).each do |m|
    entry['about'] << m[0]
  end

  regex = /\.{3}(\d+ KM\/H)\s+(.+MOVEMENT.+)\s+.+\.{3}(\d* MB)/
  res.body.scan(regex).each do |matches|
    entry['maxSustainedWinds']  = matches[0]
    entry['presentMovement']  = matches[1]
    entry['minCentralPressure'] = matches[2]
  end

  if params[:format] == 'jsonp'
    "#{ params[:callback] || 'callback' }(#{ entry.to_json });"
  else
    entry.to_json
  end
end

# Builds ruby hashes from old school location strings, e.g. "19.7N 94.7W"
def location_to_hash(location)
  return Hash[["north", "west"].zip location.split.map { |c| c.to_f }]
end

