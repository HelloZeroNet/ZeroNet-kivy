from kivy import utils

print "_PLATFORM %s" % utils.platform

platform=utils.platform
platform_name=platform

if platform=="android":
    import platform_android as platform
elif platform=="linux":
    import platform_linux as platform
else:
    raise Exception("Unsupported platform: %s" % platform)
