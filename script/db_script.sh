#!/bin/bash

table='usage'
cktime=`date +%FH%H:%M`
name=`uname -n`
inuse=`who | grep -c ':0 '`
qry="INSERT INTO $table (host, usage) VALUES ('$name',$inuse);"

number=$RANDOM
let "number %= 10"
sleep $number

export PGPASSFILE='/path/to/pgpass/file'
/usr/bin/psql -h PGSQLHOSTNAME << eof
$qry
eof
