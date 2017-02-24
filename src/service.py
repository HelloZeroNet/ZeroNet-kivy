#!/usr/bin/env python

import os
import sys

from env_json import loadEnv

env = loadEnv()

if env["platform"] == "android":
    from jnius import autoclass
    Service = autoclass('org.kivy.android.PythonService').mService

print "env %s" % env

sys.path.insert(1,  env['srcdir'])
print "srcdir: %s" % env['srcdir']
print "sys.path: %s" % sys.path

os.chdir(env['srcdir'])

print "sys.argv: %s" % sys.argv

with open(env['pidfile'], "w") as f:
    f.write(str(os.getpid()))
    f.close()

if True:  # so beautification does not move this to the top
    import zeronet


def main():
    zeronet.main()

if __name__ == '__main__':
    main()
