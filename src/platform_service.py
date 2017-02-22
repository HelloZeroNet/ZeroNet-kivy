import json
import os
import re
import shutil
import traceback

from kivy.utils import platform


def mkdirp(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)


def parseRev(f):
    file = open(f, "r")
    for line in file:
        match = re.search("^ *self\.rev = ([0-9]*)", line)
        if match:
            return int(match.group(1))


def needUpdate(src, dst, backup):
    if not os.path.exists(dst):
        return True
    conf = os.path.join(dst, "src", "Config.py")
    confsrc = os.path.join(src, "src", "Config.py")
    if os.path.exists(conf):
        return parseRev(conf) != parseRev(confsrc)
    return True  # FIXME: add logic


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
        for import_dir in ["data", "log"]:
            if os.path.exists(os.path.join(backup, import_dir)):
                try:
                    shutil.move(os.path.join(backup, import_dir),
                                os.path.join(dst,  import_dir))  # import data
                except:
                    traceback.print_exc()
                print "%s imported" % import_dir
    except:
        traceback.print_exc()


class SystemService():

    def __init__(self):
        self.dir = self.getPath()
        self.platform = platform
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

    def getPidfilePath(self):
        return "zeronet.pid"

    def run(self):
        update(self.zeroDir(), self.getPath(
            "zero"), self.getPath("zero_backup"))
        self.setEnv()
        print "Running ZeroNet"
        self.runService()
