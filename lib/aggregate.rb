def aggregate(pgresult)
  rows = pgresult.values
  st = rows[0][0]
  out = {}
  count = 0
  rows.each{|row|
    if row[0] == st
      count += row[1].to_i
    else
      out[st] = count
      st = row[0]
      count = 0
      redo
    end
  }
  return out
end