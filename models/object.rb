
class Object

  def remove_extra_spacing
    if self.is_a?(String)
      self.gsub!(/\s+/, " ")
    elsif self.is_a?(Hash)
      self.each { |k,v| v.remove_extra_spacing }
    elsif self.is_a?(Array)
      self.each { |e| e.remove_extra_spacing }
    end
  end

end

