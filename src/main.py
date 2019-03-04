from webbrowser import open as browser

from kivy.app import App
from kivy.lang import Builder

from os_platform import Service, platform
from zeronet_config import getConfigValue


class ZeronetApp(App):

    '''This is the app itself'''

    def url_click(self, url):
        full = "http://127.0.0.1:" + \
            getConfigValue(self.service.config, "ui_port", "43110") + "/" + url
        print "Opening in browser %s" % full
        browser(full)

    def build(self):
        print "Starting..."

        print "Running on platform %s" % platform

        self.service = Service()
        '''Starts 2 watchdog processes, which will then start zeronet'''
        self.service.run()

if __name__ == "__main__":
    '''Start the application'''

    if True: # TODO: really only allow this in prod
        import traceback
        import sentry_sdk
        from sentry_sdk import capture_exception
        sentry_sdk.init("https://1cc0c8280fa54361920e75f014add9fe@sentry.io/1406946")
        try:
            ZeronetApp().run()
        except Exception as e:
            traceback.print_exc()
            capture_exception(e)
    else:
        ZeronetApp().run()
