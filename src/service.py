#!/usr/bin/env python

import os
import sys

from env_json import loadEnv

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

    if SDK_INT > 26:
        manager = autoclass('android.app.NotificationManager')
        channel = autoclass('android.app.NotificationChannel')

        app_channel = channel(
          "service_zn", "ZeroNet Background Service", manager.IMPORTANCE_MIN
        )
        Service.getSystemService(manager).createNotificationChannel(app_channel)
        notifi.setChannel("service_zn")
    notification = notifi.getNotification()
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
    if True: # TODO: really only allow this in prod
        import traceback
        import sentry_sdk
        from sentry_sdk import capture_exception
        sentry_sdk.init("https://1cc0c8280fa54361920e75f014add9fe@sentry.io/1406946")
        try:
            main()
        except Exception as e:
            traceback.print_exc()
            capture_exception(e)
    else:
        main()
