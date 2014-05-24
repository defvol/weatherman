require 'uri'

module URI
  class << self

    # Public: Clean up URI and recover lost '+' replaced by sinatra's router
    #
    # uri - A string representing the URI to process
    #
    # see: http://stackoverflow.com/questions/5374470/uriinvalidurierror-bad-uriis-not-uri
    # see: https://github.com/sinatra/sinatra/issues/463
    # see: https://github.com/sinatra/sinatra/issues/638
    #
    # Returns a string representing a new URI
    def parse_with_hack(uri)
      URI.parse URI.encode(uri.strip.gsub(' ','+'))
    end

  end
end

