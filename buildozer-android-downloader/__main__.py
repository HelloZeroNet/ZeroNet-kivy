from os import path
import os
import sys
from AndroidComponent import SDK, NDK
from ConfigParser import ConfigParser as config
import errno

if len(sys.argv) < 2:
    sys.exit('Usage: %s <buildozer-config>' % sys.argv[0])

if not os.path.exists(sys.argv[1]):
    sys.exit('ERROR: Buildozer config %s was not found!' % sys.argv[1])

def recursive_if_empty(path):
    """Recursively check if empty; return True
    if everything is empty..."""
    for f in os.listdir(path):
        fp=os.path.join(path,f)
        if not os.path.isdir(fp):
            return False
        else:
            if not recursive_if_empty(fp):
                return False
    return True

b_dir=path.expanduser("~/.buildozer/android/platform/")
conf_path=path.realpath(sys.argv[1])
conf=config(conf_path)
objs=dict({"sdk":SDK,"ndk":NDK})
for thing in ("sdk","ndk"):
    n=objs[thing](conf.parseNum("android."+thing),b_dir)
    if n.exists():
        if recursive_if_empty(n.destDir):
            n.download()
        else:
            print "%s is already installed" % n.constructDir()
    else:
        n.download()
