require 'sinatra'
require 'json'
require 'net/http'
require_relative 'models/regexp'
require_relative 'models/object'

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

  current = hurricane_current(res.body)

  forecasts = []
  regex = /FORECAST VALID (\d+\/\w+) (\d+.\d+N)\s+(\d+.\d+W).*\s+MAX WIND\s+(\d+ KT).+GUSTS\s+(\d+ KT)/
  matches = res.body.scan(regex)
  matches.each do |match|
    forecasts << { id: match[0], north: match[1], west: match[2], max: match[3], gusts: match[4] }
  end

  result = { current: current, forecasts: forecasts }

  if params[:format] == 'jsonp'
    "#{ params[:callback] || 'callback' }(#{ result.to_json });"
  else
    result.to_json
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

### Extras

def hurricane_current(bulletin)
  regexps = [
    /C\w+ L\w+ NEAR (?<center>\d+\.\d+N\s+\d+\.\d+W)\s+AT\s+(?<effective>.+)/,
    /PRESENT MOVEMENT (?<movement>.+)/,
    /E\w+ MIN\w+ C\w+ PRESSURE\s+(?<minCentralPressure>\d+ MB)/
  ]
  hurricane = Regexp.batch_as_hash(regexps, bulletin)

  hurricane['winds'] = {
    maxSustainedWindsWithGusts: bulletin.scan(/^MAX S\w+ WINDS.+./).first || "",
    direction: bulletin.scan(/(^\d+ KT\.{7}.+)./).flatten || [],
    seas: bulletin.scan(/^\d+ FT SEAS\.{2}.+/).first || ""
  }

  hurricane.remove_extra_spacing
end

# Builds ruby hashes from old school location strings, e.g. "19.7N 94.7W"
def location_to_hash(location)
  return Hash[["north", "west"].zip location.split.map { |c| c.to_f }]
end

