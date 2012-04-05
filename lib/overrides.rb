class PGresult
  def to_s
    out = []
    self.values().each{|row|
      t = row.inject{|sum, x| sum+" | #{x}"}
      out << t
    }
    return out.inject{ |sum, x| sum + "\n#{x}"}
  end 
end

class Hash
  def to_csv
    out = []
    self.each{|k,v| out << "#{k},#{v}"}
    return out
  end
end