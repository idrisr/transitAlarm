TMPDIR=tmp
STOPS=$(TMPDIR)/stops.txt
DBPASSWORD=password

cta : clean makedirs unzip changeAgencyName removequotes removespaces fixstops loaddb fixbadlatlon addAgencyID createRouteTrip
	gtfs=CTA.zip
	DBNAME=cta
	SQLSCRIPT=load_cta.sql
	SQLUPDATEBADLATLON=$(TMPDIR)/update_bad_lat_lon.sql
	SQLGETBADLATLON=get_bad_lat_lon.sql
	BADLATLON=$(TMPDIR)/bad_lat_lon

metra: clean unzip removequotes removespaces loaddb addAgencyID createRouteTrip
	gtfs=metra.zip
	SQLSCRIPT=load_metra.sql
	DBNAME=metra

COMMON_DIR=.
ADDAGENCYID_SQL=$(COMMON_DIR)/addAgencyIDtoRoute.sql
CREATEROUTETRIP_SQL=$(COMMON_DIR)/longestTripForRoute.sql

# MD5 (CTA.zip) = 115a397cdf5a38d2ef22cf3a74bb67c5
# http://www.transitchicago.com/downloads/sch_data/
# Fri Apr 22 12:04:07 CDT 2016

# MD5 (metra_20130308_0424.zip) = 8fdaf34ffa53c6f5c6846ce3b1f27437
# http://www.gtfs-data-exchange.com/agency/metra/
# http://gtfs.s3.amazonaws.com/metra_20130308_0424.zip
# Sat Apr 23 17:22:53 CDT 2016

help:
	# @echo "see https://developers.google.com/transit/gtfs/reference"
	# @echo ""
	# @echo "make gtfs=[pathToMyZippedgtfsfile/transit.zip]"
	# @echo "example usage: make gtfs=CTA/google_transit.zip"

makedirs:
	mkdir -p $(TMPDIR)

unzip:
	@mkdir -p $(TMPDIR)
	@unzip $(gtfs) trips.txt      -d $(TMPDIR)
	@unzip $(gtfs) stop_times.txt -d $(TMPDIR)
	@unzip $(gtfs) stops.txt      -d $(TMPDIR)
	@unzip $(gtfs) shapes.txt     -d $(TMPDIR)
	@unzip $(gtfs) routes.txt     -d $(TMPDIR)
	@unzip $(gtfs) agency.txt     -d $(TMPDIR)

changeAgencyName:
	gsed -i 's/Chicago Transit Authority/CTA/g' $(TMPDIR)/agency.txt

removequotes:
	for f in $(TMPDIR)/*; do      \
		gsed -i 's/"//g' $$f; \
	done

removespaces:
	for f in $(TMPDIR)/*; do      \
		gsed -i "s/, \+/,/g" $$f; \
	done

fixstops:
	# the stops.txt file has extra columns with no headers, and has its headers in the wrong order
	# CTAFTWTF
	tail -n +2 $(STOPS) | awk -v OFS=',' -F, '{print $$1,$$2,$$3,$$4,$$7,$$8}' > $(STOPS).new
	gsed -i '1s/^/stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon\n/' $(STOPS).new
	mv $(STOPS) $(STOPS).old
	mv $(STOPS).new $(STOPS)

loaddb:
	cat $(SQLSCRIPT) | mysql -u root -p$(DBPASSWORD)

fixbadlatlon:
	mysql -N -u root -p$(DBPASSWORD) < $(SQLGETBADLATLON) > $(BADLATLON)
	while read STOP_ID; do\
		awk -F, '$$1==var {print "UPDATE stops SET stop_lat=" $$5 ",stop_lon=" $$6 " WHERE stop_id=" $$1 ";"}' var="$$STOP_ID" $(STOPS).old;\
	done < $(BADLATLON) > $(SQLUPDATEBADLATLON)
	cat $(SQLUPDATEBADLATLON) | mysql -u root -p$(DBPASSWORD) -A cta

addAgencyID:
	sed "s/DB_REPLACE_ME/$(DBNAME)/g" $(ADDAGENCYID_SQL) | mysql -u root -p$(DBPASSWORD);

createRouteTrip:
	sed "s/DB_REPLACE_ME/$(DBNAME)/g" $(CREATEROUTETRIP_SQL) | mysql -u root -p$(DBPASSWORD);

clean:
	rm -rf $(TMPDIR)
