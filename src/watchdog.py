import os
import sys
from time import sleep

import os_platform as platform
from env_json import loadEnv

if "watchdog_id" not in os.environ:
    raise Exception("No watchdog id!")
id = int(os.environ["watchdog_id"])
print "This is watchdog %s" % id

service = platform.Service()
service.setPid("watchdog%s" % str(id), os.getpid())


def isRunning(what):
    i = service.isRunning(what)
    if not i:
        print "%s is not running, starting now" % what
    # else:
    #    print "%s is running, pid=%s" % (what,service.getPid(what))
    return i

while(True):  # runs forever
    sleep(1)  # delay first, so processes can start up
    if id == 1:  # the first watchdog checks if watchdog2 and zeronet are running and starts them
        if not isRunning("watchdog2"):
            # if not os.fork():
            service.startWatchdog(2)
            # exit(0)
        if not isRunning("zeronet"):
            # if not os.fork():
            service.runZero()
            # exit(0)
    elif id == 2:  # the second check only if the first is running
        if not isRunning("watchdog1"):
            # if not os.fork():
            service.startWatchdog(1)
            # exit(0)
