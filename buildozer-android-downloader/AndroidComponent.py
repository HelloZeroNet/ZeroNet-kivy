from __future__ import print_function

from os import path
from uuid import uuid4 as uuid


import os, sys
import zipfile
import requests
from clint.textui import progress

import errno


def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

def getunzipped(theurl, thedir, what):
  name = os.path.join("/","tmp",str(uuid())+".zip")
  try:
#    name, hdrs = urllib.urlretrieve(theurl, name)
    dlwithprogress(theurl,name, what)
  except IOError, e:
    print("Can't retrieve %r to %r: %s" % (theurl, thedir, e))
    return
  try:
    z = zipfile.ZipFile(name)
  except zipfile.error, e:
    print("Bad zipfile (%r): %s" % (theurl, e))
    return
  for n in z.namelist():
    if n.endswith("/"):
        continue
    dest = os.path.join(thedir, n)
    destdir = os.path.dirname(dest)
    if not os.path.isdir(destdir):
      os.makedirs(destdir)
    try:
        f = open(dest, 'w')
        data = z.read(n)
        f.write(data)
        f.close()
        #print(n)
    except IOError, e:
        print("An error occured @ file %s: %s" % (n,e))
  z.close()
  os.unlink(name)
  print("Successfully downloaded %s" % what)

def dlwithprogress(url,dest,what):
    with open(dest, "wb") as f:
        print("Downloading %s from %s" % (what,url))
        r = requests.get(url, stream=True)
        total_length = int(r.headers.get('content-length'))
        if "DISABLE_PROGRESS" in os.environ:
            count_progress=-1
            count_max=(total_length/1024) + 1
            count_current=0
            for chunk in r.iter_content(chunk_size=1024):
                count_current=count_current+1
                count_new=count_current//(count_max//100)
                if count_progress < count_new:
                    for i in range(count_progress,count_new):
                        count_progress=count_progress+1
                        if not count_progress%10:
                            sys.stdout.write("["+str(count_progress)+"%]")
                        else:
                            sys.stdout.write('.')
                        sys.stdout.flush()
                f.write(chunk)
                f.flush()
            print("")
        else:
            for chunk in progress.bar(r.iter_content(chunk_size=1024), expected_size=(total_length/1024) + 1):
                if chunk:
                    f.write(chunk)
                    f.flush()


class AndroidComponent:
    def __init__(self, version, bpath): #things like the url are defined below
        self.version=version
        self.version_str=str(version)
        self.url=self.constructUrl()
        self.destDir=path.join(bpath,self.constructDir())
        self.bpath=bpath
    def exists(self):
        return path.exists(self.destDir)
    def download(self):
        mkdir_p(self.destDir)
        getunzipped(self.url,path.join(self.bpath,self.constructDir(True)),self.constructDir())


class SDK(AndroidComponent):
    def constructDir(self,zip=False):
        return "android-sdk-"+self.version_str
    def constructUrl(self):
        #return "http://dl.google.com/android/android-sdk_r"+self.version_str+"-linux.tgz"
        return "https://dl.google.com/android/repository/tools_r"+self.version_str+"-linux.zip"
        #return "https://dl.google.com/android/repository/sdk-tools-linux-"+self.version_str+".zip"

class NDK(AndroidComponent):
    def constructDir(self,zip=False):
        if zip:
            return "" #this is because the paths in the zip already start with android-ndk-r$VER/
        return "android-ndk-r"+self.version_str
    def constructUrl(self):
        #return "https://example.com"
        return "https://dl.google.com/android/repository/android-ndk-r"+self.version_str+"-linux-x86_64.zip"
