# Linux Specific Code
import os
import sys
import threading
from os import path
from subprocess import PIPE, Popen

from platform_service import SystemService


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

    def runService(self):
        env = os.environ
        env['env.json'] = getDir("env.json")
        self.process = Popen([os.path.join(realpath(), "service.py")], env=env)
        self.running = True
        self.thread = pipeThread(1, "ZeroNet", 1, self.process)
        self.thread.start()
