import re

class ConfigParser:
    def __init__(self,f):
        self.file=f
        with open(f) as f_:
            self.content=f_.read()
    def parseNum(self,key):
        matches=re.finditer("^ *"+key.replace(".","\\.")+" *= *([0-9]+) *",self.content,re.MULTILINE)
        for match in matches:
            return int(match.group(1))
        print "ERROR: Setting %s not found or has invalid value" % key
        return False
    def parse(self,key):
        matches=re.finditer("^ *"+key.replace(".","\\.")+" *= *(.+) *",self.content,re.MULTILINE)
        for match in matches:
            return match.group(1)
        print "ERROR: Setting %s not found or has invalid value" % key
        return False
