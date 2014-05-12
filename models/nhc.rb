module NHC
  # Public: Parse content from a NHC forecast advisory page using regex
  #
  # advisory - The String (page content) to be parsed
  #
  # Examples
  #
  #   parse_forecast_advisory(res.body)
  #   # => {:center=>"23.7N 99.9W", :effective=>"17/0900Z"}
  #
  # Returns a Hash object with parsed values
  def NHC.parse_forecast_advisory(advisory)
    regexps = [
      /C\w+ L\w+ NEAR (?<center>\d+\.\d+N\s+\d+\.\d+W)\s+AT\s+(?<effective>.+)/,
      /PRESENT MOVEMENT (?<movement>.+)/,
      /E\w+ MIN\w+ C\w+ PRESSURE\s+(?<minCentralPressure>\d+ MB)/
    ]
    result = Regexp.batch_as_hash(regexps, advisory)

    result[:winds] = {
      maxSustainedWindsWithGusts: advisory.scan(/^MAX S\w+ WINDS.+./).first || "",
      direction: advisory.scan(/(^\d+ KT\.{7}.+)./).flatten || [],
      seas: advisory.scan(/^\d+ FT SEAS\.{2}.+/).first || ""
    }

    regex = /(FORECAST|OUTLOOK) VALID (?<id>\d+\/\w+) (?<north>\d+.\d+N)\s+(?<west>\d+.\d+W)(.+)?\s+MAX WIND\s+(?<max>\d+ KT).+ (?<gusts>\d+ KT)/
    keys = [:id, :north, :west, :max, :gusts]
    result[:forecasts] = advisory.scan_as_hash_array(regex, keys)

    result.remove_extra_spacing
  end

end

