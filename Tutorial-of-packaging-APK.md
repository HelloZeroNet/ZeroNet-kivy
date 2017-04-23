# Guide:

Tested on Ubuntu 16.04

Required things:
 - A phone or armv7 emulator (can't build for non-arm currently)
 - Git
 - Make
 - Docker or Vagrant

## Initial Steps
 - First `git clone https://github.com/HelloZeroNet/ZeroNet-kivy --recursive`
 - Now verify the contents in `src/zero`
 - Now run `make prebuild`

## Docker
 - First you need to build the latest kivy image using `make docker-build`
 - Now run `make docker-pre` to download some other things


## Vagrant
(This part may be out-of-date)
 - First run `vagrant up`
 - This should install all the things
 - Now run `make -C /vagrant pre`
 - Now you can `vagrant ssh` inside your vm

### Building
- To build run `make docker` for docker and `make -C /vagrant apk` for vagrant
- To test you need adb installed **outside** of docker/vagrant
  - If you got it installed run `make docker-test`
  - If you are using an emulator append `ADB_FLAG=-e` to the command
- If building succeeds a bin folder with the ZeroNet.apk appears

### Debugging
 - Running `make docker-test` should start adb logcat
 - Additional logs are in `/storage/emulated/0/Android/data/net.mkg20001.zeronet/files/zero/log`
