#!/usr/bin/env bash

DB=ctametra

for table in $(mysql -uroot -ppassword -A ctametra -N -B -e "show tables"); do
      ./_tableDump.sh ${DB} ${table}
done
