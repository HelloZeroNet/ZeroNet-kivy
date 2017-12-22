# Guide:

Tested on Ubuntu 16.04

Required things:
 - A phone or armv7 emulator (can't build for non-arm currently)
 - Git
 - Make
 - ADB
 - Docker or Vagrant (for vagrant please skip to the bottom)

## Initial Steps
 - First `git clone https://github.com/HelloZeroNet/ZeroNet-kivy --recursive`
 - Now verify the contents in `src/zero`

## Setup
 - First you need to generate an environment config. Do this using `make .env`
 - After that prepare the build using `make .pre`

## Building
 - Run `make debug` to build the debug version of the app
 - Run `make release` to build the release version of the app
 - If building succeeds a bin folder with the ZeroNet.apk appears
 - Run `make run` to test the app on the connected phone
   - If you are using an emulator append `ADB_FLAG=-e` to the command

## Debugging
 - Running `make test` should start adb logcat
 - Additional logs are in `/storage/emulated/0/Android/data/net.mkg20001.zeronet/files/zero/log`
 - If `make test` does not work try `make run`

## Vagrant
 - First run `vagrant up`
 - This should create and prepare the vm

### Building
- Run all the commands **inside** the vagrant VM (Use `vagrant ssh` to enter the vm)
- To test you need adb installed. Run `make run` or `make test` **outside** the VM
  - If you got it installed run `make run`
  - If you are using an emulator append `ADB_FLAG=-e` to the command
