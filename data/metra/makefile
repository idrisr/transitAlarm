all: clean unzip removequotes removespaces loaddb createRouteTrip

TMPDIR=tmp
gtfs?=metra.zip
STOPS=$(TMPDIR)/stops.txt
MAKEDB_SQL=load_metra.sql
SQLGETBADLATLON=get_bad_lat_lon.sql
BADLATLON=$(TMPDIR)/bad_lat_lon
DBPASSWORD=password
DBNAME=metra
SQLUPDATEBADLATLON=$(TMPDIR)/update_bad_lat_lon.sql
COMMON_DIR=../common

CREATEROUTETRIP_SQL=$(COMMON_DIR)/longestTripForRoute.sql
ADDAGENCYID_SQL=$(COMMON_DIR)/addAgencyIDtoRoute.sql

# MD5 (metra_20130308_0424.zip) = 8fdaf34ffa53c6f5c6846ce3b1f27437
# http://www.gtfs-data-exchange.com/agency/metra/
# http://gtfs.s3.amazonaws.com/metra_20130308_0424.zip
# Sat Apr 23 17:22:53 CDT 2016

help:
	# @echo "see https://developers.google.com/transit/gtfs/reference"
	# @echo ""
	# @echo "make gtfs=[pathToMyZippedgtfsfile/transit.zip]"
	# @echo "example usage: make gtfs=CTA/google_transit.zip"

unzip:
	@mkdir -p $(TMPDIR)
	@unzip $(gtfs) trips.txt      -d $(TMPDIR)
	@unzip $(gtfs) stop_times.txt -d $(TMPDIR)
	@unzip $(gtfs) stops.txt      -d $(TMPDIR)
	@unzip $(gtfs) shapes.txt     -d $(TMPDIR)
	@unzip $(gtfs) routes.txt     -d $(TMPDIR)
	@unzip $(gtfs) agency.txt     -d $(TMPDIR)
	dos2unix $(TMPDIR)/*

removequotes:
	for f in $(TMPDIR)/*; do      \
		gsed -i 's/"//g' $$f; \
	done

removespaces:
	for f in $(TMPDIR)/*; do      \
		gsed -i "s/, \+/,/g" $$f; \
	done

loaddb:
	sed "s/DB_REPLACE_ME/$(DBNAME)/g" $(MAKEDB_SQL) | mysql -u root -p$(DBPASSWORD);

createRouteTrip:
	sed "s/DB_REPLACE_ME/$(DBNAME)/g" $(CREATEROUTETRIP_SQL) | mysql -u root -p$(DBPASSWORD);

clean:
	rm -rf $(TMPDIR)
