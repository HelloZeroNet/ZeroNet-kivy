from webbrowser import open as browser

from kivy.app import App
from kivy.lang import Builder

from os_platform import Service, platform, wrapSentry
from zeronet_config import getConfigValue


class ZeronetApp(App):

    '''This is the app itself'''

    def url_click(self, url):
        full = "http://127.0.0.1:" + \
            getConfigValue(self.service.config, "ui_port", "43110") + "/" + url
        print("Opening in browser %s" % full)
        browser(full)

    def build(self):
        print("Starting...")

        print("Running on platform %s" % platform)

        self.service = Service()
        '''Starts 2 watchdog processes, which will then start zeronet'''
        self.service.run()

if __name__ == "__main__":
    '''Start the application'''

    wrapSentry(ZeronetApp().run)
