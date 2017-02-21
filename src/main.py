from kivy.app import App
from kivy.lang import Builder


class ZeronetApp(App):

    '''This is the app itself'''

    def build(self):
        print "Starting..."

        from kivy import utils

        print "Running on platform %s" % utils.platform

        from os_platform import Service

        '''Start the service'''  # TODO: check if it crashed/stopped
        Service().run()

if __name__ == '__main__':
    '''Start the application'''

    ZeronetApp().run()
