import json
import os
import shutil
import traceback

from kivy.utils import platform


def mkdirp(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)


def needUpdate(src, dst, backup):
    if not os.path.exists(dst):
        return True
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
        env = dict({'ZERONET_DIR': self.getPath(
            "zero"), 'PLATFORM': str(self.platform)})
        with open(self.getEnvJsonPath(), "w") as f:
            json.dump(env, f)

    def getEnvJsonPath(self):
        return "env.json"

    def run(self):
        update(self.zeroDir(), self.getPath(
            "zero"), self.getPath("zero_backup"))
        self.setEnv()
        print "Running ZeroNet"
        self.runService()
