from jnius import autoclass

import os
import shutil
from distutils.version import StrictVersion
import json
import traceback
from plyer.platforms.android import activity, SDK_INT # plyer in pip is old and has bugs, so need to download source code manually from plyer repo to replace all the plyer source code folder downloaded by buildozer

Environment = autoclass('android.os.Environment')
mActivity = autoclass('org.kivy.android.PythonActivity').mActivity
extdir = mActivity.getExternalFilesDir(None).getPath() # getExternalFilesDir points to Emulated_storage/Android/data/package_name(e.g.android.test.myapp17)/files/
ext_kivylogs = os.path.join(extdir, 'kivy_logs')
from kivy.config import Config
Config.set('kivy', 'log_dir', ext_kivylogs) # Set kivy logs to ExternalFilesDir, so that users can see them without root
Config.write()

srcinject = os.path.join(os.environ['ANDROID_APP_PATH'],  'inject.py_') # The original filename is inject.py_ to avoid converting to pyo file while packing
dstinject = os.path.join(extdir, 'inject.py')
pm = mActivity.getPackageManager()
APK_version = pm.getPackageInfo(activity.getPackageName(), 0).versionName
print " APK_version: %s " %  APK_version
needupdate = False
if not os.path.exists(os.path.join(extdir, 'env_ext.json')):
    needupdate = True
else:
    with open(os.path.join(extdir, 'env_ext.json'), 'r') as fx:
         env_ext_old = json.load(fx)
    APK_version_old = env_ext_old['APK_version'] # Read APK_version from file to detemin whether need to update
    if StrictVersion(APK_version) > StrictVersion(APK_version_old):
        needupdate = True
if needupdate == True:
    print "Need to update inject.py"
    try:
        if os.path.exists(os.path.join(extdir, "inject_backup.py")):
            os.remove(os.path.join(extdir, "inject_backup.py")) # Prepare for updating the exiting code
            print "inject_backup.py removed"
        if os.path.exists(dstinject):
            os.rename(dstinject, os.path.join(extdir, "inject_backup.py"))
            print "inject.py renamed to inject_backup.py"
        try:
            shutil.copyfile(srcinject, dstinject) # Copy inject.py to ExternalFilesDir, so that users can modify it without root
        except:
            traceback.print_exc()
        print "inject.py_ copied to external inject.py"
    except:
        traceback.print_exc()
        
sys.path.insert(1,  extdir)  # Use inject.py in ExternalFilesDir
print "sys.path: %s" % sys.path 
import inject
def main():
    inject.ZeronetApp().run()

if __name__ == '__main__':
    main()
