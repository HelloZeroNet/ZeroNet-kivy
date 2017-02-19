import os, json, shutil

def mkdirp(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)

def update(extdir,srczerodir,dstzerodir):
    try:
        if os.path.exists(os.path.join(extdir, "zero_backup")):
            shutil.rmtree(os.path.join(extdir, "zero_backup")) # Prepare for updating the exiting code and importing data
            print "zero_backup removed"
        if os.path.exists(dstzerodir):
            os.rename(dstzerodir,  os.path.join(extdir, "zero_backup"))
            print "zero renamed to zero_backup"
        try:
            shutil.copytree(srczerodir, dstzerodir ) # Copy ZeroNet entirely to external, shutil.copytree will refuse to copy if destination exists.
        except:
            traceback.print_exc()
        print "zero copied to external zero"
        for import_dir in ["data","log"]:
            if os.path.exists(os.path.join(extdir, "zero_backup",import_dir)):
                try:
                    shutil.move(os.path.join(extdir, "zero_backup",import_dir),  os.path.join(dstzerodir,  import_dir)) # import data
                except:
                    traceback.print_exc()
                print "%s imported" % import_dir
    except:
        traceback.print_exc()

class SystemService():
    def __init__(self):
        self.dir=self.getPath()
        print "ZeroNet_Dir=%s" % self.dir
        mkdirp(self.dir)
    def setEnv(self):
        print "Setting Env"
        env = dict({'ZERONET_DIR': self.getPath("zero")})
        with open(self.getEnvJsonPath(), "w") as f:
            json.dump(env, f)
    def getEnvJsonPath(self):
        return "env.json"
    def run(self):
        update(self.getPath(),self.zeroDir(),self.getPath("zero"))
        self.setEnv()
        print "Running ZeroNet"
        self.runService()
