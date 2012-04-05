require 'pg'

conn = PGconn.connect('pgserver',nil,nil,nil,'database','user','password')

$query_latest = "SELECT u.host,u.usage,v.lt
FROM usage AS u
  INNER JOIN (
    SELECT host,max(logtime) AS lt FROM usage GROUP BY host
  ) v
  ON u.host = v.host AND u.logtime = v.lt
ORDER BY host;"

###
### Start of update
###
latest = conn.exec($query_latest)
latest.each{|r|
  host = r['host']
  tstamp = r['lt']
  in_use = r['usage']

  m = Machine.find_by_name(host)
  if m.nil?
    warn 'New machine found, please add lab data manually.'
    warn "details:\n#{r}"
    m = Machine.new()
    m.name = host
  end
  # handle what happens if no machine found
	
  m.available = in_use.to_i.zero?
  m.last_checked = tstamp
  updated = Time.parse(tstamp)
  if updated < 1.week.ago
    m[:stale] = true
    m[:offline] = false
    m[:available] = false
  elsif updated < 1.hours.ago
    m[:offline] = true
    m[:stale] = false
    m[:available] = false
  else
    m[:offline] = false
    m[:stale] = false
  end
	m.save()
}
Rails.cache.delete('estimation_cache')