import errno
import json
import os
import re
import shutil
import traceback

from kivy.utils import platform

import os_platform
from zeronet_config import parseConfig, saveConfigValue


def mkdirp(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)


def parseRev(f):
    file = open(f, "r")
    for line in file:
        match = re.search("^ *self\.rev = ([0-9]*)", line)
        if match:
            return int(match.group(1))

def findFile(files):
    for f in files:
        if os.path.exists(f):
            return f
    return None


def needUpdate(src, dst, backup):
    if not os.path.exists(dst):
        return True
    conf = findFile([os.path.join(dst, "src", "Config.py"),os.path.join(dst, "src", "Config.py_")])
    confsrc = findFile([os.path.join(src, "src", "Config.py"),os.path.join(src, "src", "Config.py_")])
    if conf is not None and confsrc is not None:
        return parseRev(conf) < parseRev(confsrc)
    else:
        print "Some files are missing, need to update"
        return True


def update(src, dst, backup):
    if not needUpdate(src, dst, backup):
        print "update not required, skipping"
        return
    try:
        if os.path.exists(backup):
            # Prepare for updating the exiting code and importing data
            shutil.rmtree(backup)
            print "zero_backup removed"
        if os.path.exists(dst):
            os.rename(dst,  backup)
            print "zero renamed to zero_backup"
        try:
            # Copy ZeroNet entirely to external, shutil.copytree will refuse to
            # copy if destination exists.
            shutil.copytree(src, dst)
        except:
            traceback.print_exc()
        print "zero copied to external zero"
        if os.path.exists(backup):
            for import_dir in ["data", "log", "zeronet.conf"]:
                if os.path.exists(os.path.join(backup, import_dir)):
                    try:
                        shutil.move(os.path.join(backup, import_dir),
                                    os.path.join(dst,  import_dir))  # import data
                    except:
                        traceback.print_exc()
                    print "%s imported" % import_dir
    except:
        traceback.print_exc()


def setConfig(conf):
    # no need to check if config exists, will return {} if it doesn't
    c = parseConfig(conf)

    def defaultValue(key, value):
        if key not in c:
            print "Applying default value %s for field %s" % (value, key)
            saveConfigValue(conf, key, value)
    defaultValue("language", os_platform.getSystemLang())
    defaultValue("keep_ssl_cert", "")
    if os_platform.getDebug():
        defaultValue("debug", "")
        # Optional, if you are already running a zeronet instance
        # defaultValue("fileserver_port","15444")
        # defaultValue("ui_port","8898")


def check_pid(pid):
    """Check whether pid exists in the current process table.
    UNIX only.
    """
    if pid < 0:
        return False
    if pid == 0:
        # According to "man 2 kill" PID 0 refers to every process
        # in the process group of the calling process.
        # On certain systems 0 is a valid PID but we have no way
        # to know that in a portable fashion.
        #raise ValueError('invalid PID 0')
        return False
    try:
        os.kill(pid, 0)
    except OSError as err:
        if err.errno == errno.ESRCH:
            # ESRCH == No such process
            return False
        elif err.errno == errno.EPERM:
            # EPERM clearly means there's a process to deny access to
            return True
        else:
            # According to "man 2 kill" possible error values are
            # (EINVAL, EPERM, ESRCH)
            raise
    else:
        return True


class SystemService():

    def __init__(self):
        self.dir = self.getPath()
        self.platform = platform
        self.count = 0
        self.config = os.path.join(self.getPath("zero"), "zeronet.conf")
        print "ZeroNet_Dir=%s" % self.dir
        mkdirp(self.dir)

    def setEnv(self):
        print "Setting Env"
        env = dict(
            {'srcdir': self.getPath("zero"),
             'platform': str(self.platform),
             'pidfile': self.getPidfilePath()}
        )
        with open(self.getEnvJsonPath(), "w") as f:
            json.dump(env, f)

    def getEnvJsonPath(self):
        return "env.json"

    def getPidfilePath(self, what="zeronet"):
        return what + ".pid"

    def getPid(self, what="zeronet"):
        pidfile = self.getPidfilePath(what)
        if not os.path.exists(pidfile):
            return 0  # if the pidfile got deleted by accident, zeronet has it's own lock file
        with open(pidfile, 'r') as f:
            try:
                pid = int(f.readline())
            except ValueError:
                return 0
        return pid

    def setPid(self, what="zeronet", pid=0):
        open(self.getPidfilePath(what), "w").write(str(pid))

    def isRunning(self, what="zeronet"):
        return check_pid(self.getPid(what))

    def run(self):
        update(self.zeroDir(), self.getPath(
            "zero"), self.getPath("zero_backup"))
        setConfig(self.config)
        self.setEnv()
        # print "Running Watchdogs"
        # self.startWatchdog(1)
        # self.startWatchdog(2)
        self.runZero()

    def runZero(self):
        print "Running ZeroNet"
        self.runService()
