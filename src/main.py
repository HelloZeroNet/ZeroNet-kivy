from kivy.app import App
from kivy.lang import Builder

from os_platform import Service,platform


class ZeronetApp(App):

    '''This is the app itself'''

    def build(self):
        print "Starting..."

        print "Running on platform %s" % platform

        '''Start the service'''  # TODO: check if it crashed/stopped
        Service().run()

if __name__ == '__main__':
    '''Start the application'''

    ZeronetApp().run()
