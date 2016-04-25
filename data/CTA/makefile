all: clean makedirs unzip changeAgencyName removequotes removespaces fixstops loaddb fixbadlatlon addAgencyID createRouteTrip

TMPDIR=tmp
gtfs?=CTA.zip
STOPS=$(TMPDIR)/stops.txt
SQLSCRIPT=load_cta.sql
SQLGETBADLATLON=get_bad_lat_lon.sql
BADLATLON=$(TMPDIR)/bad_lat_lon
DBPASSWORD=password
SQLUPDATEBADLATLON=$(TMPDIR)/update_bad_lat_lon.sql

ADDAGENCYID_SQL=add_agencyID_to_route.sql
CREATEROUTETRIP_SQL=longestTripForRoute.sql

# MD5 (CTA.zip) = 115a397cdf5a38d2ef22cf3a74bb67c5
# http://www.transitchicago.com/downloads/sch_data/
# Fri Apr 22 12:04:07 CDT 2016

help:
	# @echo "see https://developers.google.com/transit/gtfs/reference"
	# @echo ""
	# @echo "make gtfs=[pathToMyZippedgtfsfile/transit.zip]"
	# @echo "example usage: make gtfs=CTA/google_transit.zip"

makedirs:
	mkdir -p $(TMPDIR)

unzip:
	unzip $(gtfs) trips.txt
	unzip $(gtfs) stop_times.txt
	unzip $(gtfs) stops.txt
	unzip $(gtfs) shapes.txt
	unzip $(gtfs) routes.txt
	unzip $(gtfs) agency.txt
	mv *txt $(TMPDIR)

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
	mysql -u root -p$(DBPASSWORD) < $(ADDAGENCYID_SQL)

createRouteTrip:
	mysql -u root -p$(DBPASSWORD) < $(CREATEROUTETRIP_SQL)

clean:
	rm -rf $(TMPDIR)
