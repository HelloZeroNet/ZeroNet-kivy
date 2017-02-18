import os
import sys
import json

with open('env.json', 'r') as f:
     env = json.load(f)
dstzerodir = env['dstzerodir'] # Read dstzerodir from file
print dstzerodir
sys.path.insert(1,  dstzerodir) 
print "sys.path: %s" % sys.path 
import zeronet

def main():
    zeronet.main()

if __name__ == '__main__':
    main()
