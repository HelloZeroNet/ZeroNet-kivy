from kivy.utils import platform

if platform=="android":
    from platform_android import *
elif platform=="linux":
    from platform_linux import *
else:
    raise Exception("Unsupported platform: %s" % platform)
