#!/usr/bin/env bash

dbs=( cta metra )
tables=( agency routeTrip routes shapes stop\\_times stops trips )
user=root
password=password

for table in "${tables[@]}"
do
    for db in "${dbs[@]}" 
    do
        mysqlshow -u${user} -p${password} ${db} "${table}" 2> /dev/null
        echo ""
    done
done

