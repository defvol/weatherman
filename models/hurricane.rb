require 'net/http'
require_relative 'regexp'
require_relative 'object'
require_relative 'string'

class Hurricane
  attr_accessor :center, :effective, :movement, :minCentralPressure, :winds, :forecasts

  def self.from_url(url)
    self.new.update_from_url!(url)
  end

  def update(attributes = {})
    begin
      attributes.each { |key, value| self.send("#{key}=", value) }
    rescue NoMethodError
      # Nothing to do yet
    end
  end

  def update_from_url!(url)
    if url =~ /nhc\.noaa\.gov.+fstadv/
      update_from_forecast_advisory download(url)
    end
    self
  end

  def download(url)
    url = URI(url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    res.body
  end

  def update_from_forecast_advisory(bulletin)
    regexps = [
      /C\w+ L\w+ NEAR (?<center>\d+\.\d+N\s+\d+\.\d+W)\s+AT\s+(?<effective>.+)/,
      /PRESENT MOVEMENT (?<movement>.+)/,
      /E\w+ MIN\w+ C\w+ PRESSURE\s+(?<minCentralPressure>\d+ MB)/
    ]
    hash_from_regexps = Regexp.batch_as_hash(regexps, bulletin)
    update hash_from_regexps.remove_extra_spacing

    self.winds = {
      maxSustainedWindsWithGusts: bulletin.scan(/^MAX S\w+ WINDS.+./).first || "",
      direction: bulletin.scan(/(^\d+ KT\.{7}.+)./).flatten || [],
      seas: bulletin.scan(/^\d+ FT SEAS\.{2}.+/).first || ""
    }.remove_extra_spacing

    self.forecasts = forecasts_from_bulletin(bulletin).remove_extra_spacing
  end

  def to_hash
    hash = {}
    self.instance_variables.sort.each do |var|
      key = var.to_s.sub('@', '').to_sym
      hash[key] = self.instance_variable_get var
    end
    hash
  end

  def forecasts_from_bulletin(bulletin)
    regex = /(FORECAST|OUTLOOK) VALID (?<id>\d+\/\w+) (?<north>\d+.\d+N)\s+(?<west>\d+.\d+W)(.+)?\s+MAX WIND\s+(?<max>\d+ KT).+ (?<gusts>\d+ KT)/
    keys = [:id, :north, :west, :max, :gusts]
    bulletin.scan_as_hash_array(regex, keys)
  end

end

