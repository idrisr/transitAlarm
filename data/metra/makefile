all: clean unzip removequotes removespaces loaddb

TMPDIR=csv
gtfs?=metra.zip
MAKEDB_SQL=load_metra.sql

# MD5 (metra_20130308_0424.zip) = 8fdaf34ffa53c6f5c6846ce3b1f27437
# http://www.gtfs-data-exchange.com/agency/metra/
# http://gtfs.s3.amazonaws.com/metra_20130308_0424.zip
# Sat Apr 23 17:22:53 CDT 2016

files = agency calendar calendar_dates fare_attributes fare_rules routes shapes stops stop_times trips

help:
	# @echo "see https://developers.google.com/transit/gtfs/reference"
	# @echo ""
	# @echo "make gtfs=[pathToMyZippedgtfsfile/transit.zip]"
	# @echo "example usage: make gtfs=CTA/google_transit.zip"

unzip:
	@mkdir -p $(TMPDIR)
	$(foreach file, $(files),\
		unzip $(gtfs) $(file).txt -d $(TMPDIR); \
	)
	dos2unix $(TMPDIR)/*

removequotes: $(TMPDIR)
	for f in $(TMPDIR)/*; do      \
		gsed -i 's/"//g' $$f; \
	done

removespaces:
	for f in $(TMPDIR)/*; do      \
		gsed -i "s/, \+/,/g" $$f; \
	done

loaddb:
	psql -d metra -f load_metra.sql  

clean:
	rm -rf $(TMPDIR)
