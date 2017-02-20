#!/usr/bin/env python

import json
import os
import sys

if 'env.json' in os.environ:
    with open(os.environ['env.json'], 'r') as f:
        env = json.load(f)
else:
    with open('env.json', 'r') as f:
        env = json.load(f)

print "env %s" % env

sys.path.insert(1,  env['srcdir'])
print "srcdir: %s" % env['srcdir']
print "sys.path: %s" % sys.path

with open(env['pidfile'], "w") as f:
    f.write(str(os.getpid()))
    f.close()

if True:  # so beautification does not move this to the top
    import zeronet


def main():
    zeronet.main()

if __name__ == '__main__':
    main()
