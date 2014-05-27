require 'net/http'
require_relative 'nhc'

class Hurricane
  def self.attributes
    [:center, :effective, :eyeDiameter, :movement, :minCentralPressure, :winds, :forecasts]
  end

  self.attributes.each { |p| attr_accessor p }

  include NHC

  def self.from_url(url)
    self.new.update_from_url!(url)
  end

  def update!(attributes = {})
    begin
      attributes.each { |key, value| self.send("#{key}=", value) }
    rescue NoMethodError
      # Nothing to do yet
    end
  end

  def update_from_url!(url)
    if url =~ /nhc\.noaa\.gov.+fstadv/
      update! NHC.parse_forecast_advisory(download(url))
    elsif url =~ /text\/refresh\/MIATCM/
      update! NHC.parse_forecast_advisory(download(url))
    end
    self
  end

  def download(url)
    begin
      url = URI.parse(url)
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
      res.body
    rescue URI::InvalidURIError => e
      { error: e.message }.to_json
    end
  end

  def to_hash
    hash = {}
    self.instance_variables.sort.each do |var|
      key = var.to_s.sub('@', '').to_sym
      hash[key] = self.instance_variable_get var
    end
    hash
  end

end

