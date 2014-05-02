require_relative 'match_data'

class Regexp

  def self.batch_as_hash(regexps, string)
    result = {}
    return raise "Need an array of Regexp objects" if not regexps.respond_to?(:each)
    regexps.each do |regex|
      matches = regex.match(string) || MatchData.foo
      matches.names.each { |k| result[k.to_sym] = matches[k] }
    end
    result
  end

end

