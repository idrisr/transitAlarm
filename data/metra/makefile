all: clean shapes split toxml header footer

shapes: metra_20130308_0424.zip
	mkdir -p tmp/
	unzip -p metra_20130308_0424.zip shapes.txt > tmp/shapes

split: shapes
	mkdir -p tmp/route_shapes
	tail -n +2 tmp/shapes | awk -F"," '{print >  "tmp/route_shapes/"$$1}'

toxml: split
	for f in tmp/route_shapes/*; do          \
		./parseToGPX.py < $$f > $$f.gpx;     \
		rm $$f;                              \
	done

header: toxml
	for f in tmp/route_shapes/*; do          \
		echo "$$(cat header.gpx $$f)" > $$f; \
	done;

footer: header
	for f in tmp/route_shapes/*; do          \
		echo "$$(cat $$f footer.gpx)" > $$f; \
	done;

clean:
	rm -rf tmp
