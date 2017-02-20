#!/usr/bin/env python

import json
import os
import sys

if 'env.json' in os.environ:
    with open(os.environ['env.json'], 'r') as f:
        env = json.load(f)
else:
    with open('env.json', 'r') as f:
        print "env %s" % str(f)
        env = json.load(f)

ZERONET_DIR = env['ZERONET_DIR']  # Read ZERONET_DIR from file
print ZERONET_DIR
sys.path.insert(1,  ZERONET_DIR)
print "sys.path: %s" % sys.path

if True:  # so beautification does not move this to the top
    import zeronet


def main():
    zeronet.main()

if __name__ == '__main__':
    main()
