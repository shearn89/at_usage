#!/bin/bash

table='usage'
cktime=`date +%FH%H:%M`
name=`uname -n`
inuse=`who | grep -c ':0 '`
qry="INSERT INTO $table (host, usage) VALUES ('$name',$inuse);"

export PGPASSFILE='/path/to/dbpass/file'
/usr/bin/psql -h pgserver << eof
$qry
eof
