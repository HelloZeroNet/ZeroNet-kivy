# Guide:

Tested on Ubuntu 18.04

Required things:
 - A phone or armv7 emulator (can't build for non-arm currently)
 - Git
 - Make
 - ADB
 - Docker or Vagrant

## Initial Steps
 - First `git clone https://github.com/HelloZeroNet/ZeroNet-kivy --recursive`
 - Now verify the contents in `src/zero`
 - (If you cloned without `--recursive` then run `git submodule init && git submodule update`)

## Setup

### Docker (recommended)
 - Run `make .env`. This will prompt you a few questions (you can usually leave the defaults as-is) and pull the docker-image.
 - Now run `setup` to complete the setup

### Vagrant
 - Run `vagrant up`. This will create an ubuntu 18.04 vm and run the necesarry setup-commands for you.
 - NOTES:
   - Run all the _building_ commands **inside** the vagrant VM (Use `vagrant ssh` to enter the vm)
   - Run all the commands that install the app on your phone **outside** the vagrant VM
   - To test you need adb installed. Run `make run` or `make test` **outside** the VM
     - If you got it installed run `make run`
     - If you are using an emulator append `ADB_FLAG=-e` to the command


### Local machine
 - Run `make .env`

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

### Building
- Run all the commands **inside** the vagrant VM (Use `vagrant ssh` to enter the vm)
- To test you need adb installed. Run `make run` or `make test` **outside** the VM
  - If you got it installed run `make run`
  - If you are using an emulator append `ADB_FLAG=-e` to the command
