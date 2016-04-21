#!/usr/bin/env python

import sys

if __name__ == '__main__':
    for line in sys.stdin:
        id, lat, lon, sequence, dist = line.strip().split()
        print '<wpt lat="%s" lon="%s"> </wpt>' % (lat, lon, )
