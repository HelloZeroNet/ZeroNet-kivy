# Linux Specific Code
import locale
import os
import re
import sys
import threading
from os import path
from subprocess import PIPE, Popen

from platform_service import SystemService


def getSystemLang(index=0):
    ls = locale.getdefaultlocale()
    if len(locale.getdefaultlocale()) < index:
        return "en"  # fallback
    l = ls[index]
    if l is None:
        return "en"  # No locales
    print "LOCALE: %s" % l
    match = re.search("^([a-z]{2})_[A-Z]+.*", str(l))
    if match:
        return match.group(1)
    else:
        return getSystemLang(index + 1)


def getDir(append=""):
    if len(append):
        return path.join(path.expanduser("~"), ".zeronet", append)
    else:
        return path.join(path.expanduser("~"), ".zeronet")


def realpath():
    return os.path.dirname(os.path.realpath(__file__))


class pipeThread (threading.Thread):

    def __init__(self, threadID, name, counter, args):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.counter = counter
        self.args = args

    def run(self):
        # print "Starting "+self.name
        self.args.communicate()
        print self.name + " has exited"


class Service(SystemService):

    def zeroDir(self):
        return os.path.join(realpath(), "zero")

    def getPath(self, append=""):
        return getDir(append)

    def getEnvJsonPath(self):
        return getDir("env.json")

    def getPidfilePath(self):
        return getDir("zeronet.pid")

    def runService(self):
        env = os.environ
        env['ENV_JSON'] = getDir("env.json")
        self.process = Popen([os.path.join(realpath(), "service.py")], env=env)
        self.running = True
        self.thread = pipeThread(1, "ZeroNet", 1, self.process)
        self.thread.start()
