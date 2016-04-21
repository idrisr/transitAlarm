#!/usr/bin/env python

import re
import sys

if __name__ == '__main__':
    regex = r'\s+'
    for line in sys.stdin:
        id, lat, lon, sequence, dist = re.sub(regex, '', line).split(",")
        print '<wpt lat="%s" lon="%s"> </wpt>' % (lat, lon, )
