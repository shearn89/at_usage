class PGresult
  def to_s
    out = []
    self.values().each{|row|
      t = row.inject{|sum, x| sum+" | #{x}"}
      out << t
    }
    return out.inject{ |sum, x| sum + "\n#{x}"}
  end
  
  # Returns a single value/single row/array of values,
  # depending on the result.
  def unpack
    if self.values().length == 1
      row = self.values()[0]
      if row.length == 1
        return row[0]
      else
        warn 'more than 1 column in result.'
        return row
      end
    else
      warn 'more than 1 row returned.'
      return self.values()
    end
  end
end