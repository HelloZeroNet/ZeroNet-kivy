from kivy import utils
from kivy.app import App
from kivy.lang import Builder


class ZeronetApp(App):

    '''This is the app itself'''

    def build(self):
        print "Starting..."

        from kivy import utils

        print "Running on platform %s" % utils.platform

        platform = utils.platform
        platform_name = platform

        if platform == "android":
            import platform_android as platform
        elif platform == "linux":
            import platform_linux as platform
        else:
            raise Exception("Unsupported platform: %s" % platform)

        '''Start the service'''  # TODO: check if it crashed/stopped
        platform.Service().run()

if __name__ == '__main__':
    '''Start the application'''

    ZeronetApp().run()
