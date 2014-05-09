
class String

  def scan_as_hash_array(regex, keys)
    result = []
    matches = self.scan(regex)
    matches.each { |match| result << Hash[keys.zip(match)] }
    result
  end

end

