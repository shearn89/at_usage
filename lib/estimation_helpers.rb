require 'time'
def time_query(at)
    out = """SELECT COUNT(*)
FROM usage
WHERE date_trunc('min', logtime) = date_trunc('min', TIMESTAMP '#{at.to_s}')
AND usage=1;"""
    return out
end

def deltas(thehash)
  values = nil
  if thehash.class == Hash
    values = thehash.values()
  elsif thehash.class == Array
    values = thehash
  else
    return nil
  end
  deltas = []
  values.each_index{ |i|
    begin
      deltas << values[i+1]-values[i]
    rescue NoMethodError # end of array
      return deltas
    end
  }
end

def delta_estimation(thash,steps)
  ds = deltas(thash)
  grad = ds[-steps..-1].reduce(:+).to_f / steps
  return (thash.values[-1] + grad)
end

def round_time(intime)
  five = Time.at((intime.to_f / 300).round * 300)
  fifteen = Time.at(((five + 300).to_f / 900).round * 900)
  final = fifteen - 300
  return final
end
  
def floor_time(intime)
  five = Time.at((intime.to_f / 300).floor * 300)
  fifteen = Time.at(((five + 300).to_f / 900).floor * 900)
  final = fifteen - 300
  return final
end