#!/usr/bin/env bash
# modified from here: https://stackoverflow.com/questions/4589891/mysql-dump-into-csv-text-files-with-column-names-at-the-top

DBNAME=$1
TABLE=$2

# https://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TMPFILE=${DIR}/tempfile.csv

user=root
password=password
FNAME=${DIR}/${DBNAME}-${TABLE}-$(date +%Y.%m.%d).csv

# (1)creates empty file and sets up column names using the information_schema
mysql -u ${user} -p${password} -B -e "SELECT COLUMN_NAME FROM information_schema.COLUMNS C WHERE table_name = '$TABLE' and table_schema='${DBNAME}';"|\
grep -iv ^COLUMN_NAME$|\
sed 's/^/"/g;s/$/"/g'|\
tr '\n' ','|\
sed 's/,$//g' > $FNAME

# # #(3)dumps data from DB into TMPFILE
mysql -u ${user} -p${password} $DBNAME -B -e "SELECT * INTO OUTFILE '${TMPFILE}' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' FROM $TABLE;" 

# # #(4)merges data file and file w/ column names
sed "s///g" ${TMPFILE} >> $FNAME

# # #(5)deletes tempfile
rm -rf ${TMPFILE}
