all: runqueries dumpdata

OUTDIR=csv
DBUSER=root
DBPASSWORD=password

querys = load_combo agency routes shape stop

runqueries:
	$(foreach query, $(querys),\
		mysql -u$(DBUSER) -p$(DBPASSWORD) < sql/$(query).sql;  \
	)

dumpdata: runqueries
	./dumpdata.sh
