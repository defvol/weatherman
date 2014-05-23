
class Regexp

  def self.batch_as_hash(regexps, string)
    result = {}
    return raise "Need an array of Regexp objects" if not regexps.respond_to?(:each)
    regexps.each { |regex| result.merge! regex.to_hash(string) }
    result
  end

  def to_hash(string)
    result = {}
    matches = self.match(string)
    matches.names.each { |k| result[k.to_sym] = matches[k] } if not matches.nil?
    result
  end

end


