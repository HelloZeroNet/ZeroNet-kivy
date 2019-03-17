#!/usr/bin/env python

import os
import sys

from env_json import loadEnv
from os_platform import wrapSentry

env = loadEnv()

if env["platform"] == "android":
    import android
    from jnius import autoclass

    ANDROID_VERSION = autoclass('android.os.Build$VERSION')
    SDK_INT = ANDROID_VERSION.SDK_INT

    Service = autoclass('org.kivy.android.PythonService').mService
    notifi = autoclass("android.app.Notification$Builder")(Service)
    notifi.setContentTitle("ZeroNet")
    notifi.setContentText("ZeroNet is running")

    if SDK_INT >= 26:
        manager = autoclass('android.app.NotificationManager') # manager is NotificationManager
        channel = autoclass('android.app.NotificationChannel')
        managerID = autoclass('android.content.Context').NOTIFICATION_SERVICE

        app_channel = channel( # val mChannel = NotificationChannel(CHANNEL_ID, name, importance)
          "service_zn", "ZeroNet Background Service", manager.IMPORTANCE_MIN # val importance = NotificationManager.IMPORTANCE_DEFAULT
        )
        Service.getSystemService(managerID).createNotificationChannel(app_channel) # val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        # notificationManager.createNotificationChannel(mChannel)
        notifi.setChannel("service_zn")
#    if SDK_INT >= 28:
#        Service.startForeground(233,notifi)
#    else:
#        notification = notifi.build()
#        Service.startForeground(233,notification)
    notification = notifi.build()
    Service.startForeground(233,notification)

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
    wrapSentry(main)

