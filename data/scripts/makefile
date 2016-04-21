all: clean shapes split toxml header footer
OUTDIR = gpxfiles

help:
	@echo "see https://developers.google.com/transit/gtfs/reference"
	@echo ""
	@echo "make gtfo=[pathToMyZippedGTFOfile/transit.zip]"
	@echo "example usage: make gtfo=CTA/google_transit.zip"

shapes:
	mkdir -p $(OUTDIR)/
	unzip -p $(gtfo) shapes.txt > $(OUTDIR)/shapes

split: shapes
	mkdir -p $(OUTDIR)/route_shapes
	tail -n +2 $(OUTDIR)/shapes | awk -F"," '{print >  "$(OUTDIR)/route_shapes/"$$1}'

toxml: split
	for f in $(OUTDIR)/route_shapes/*; do          \
		./parseToGPX.py < $$f > $$f.gpx;     \
		rm $$f;                              \
	done

header: toxml
	for f in $(OUTDIR)/route_shapes/*; do          \
		echo "$$(cat header.gpx $$f)" > $$f; \
	done;

footer: header
	for f in $(OUTDIR)/route_shapes/*; do          \
		echo "$$(cat $$f footer.gpx)" > $$f; \
	done;

clean:
	rm -rf $(OUTDIR)
