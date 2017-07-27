# ZeroNet-kivy
[![Build Status](https://travis-ci.org/HelloZeroNet/ZeroNet-kivy.svg?branch=master)](https://travis-ci.org/HelloZeroNet/ZeroNet-kivy)
[简体中文](./README-zh-cn.md)

The GUI control panel and APP packaging for ZeroNet using Kivy framework
[Kivy](https://kivy.org) is an open-source cross-platform GUI framework written in Python. It works on not only Android but also iOS, even desktop (Win, Linux, Mac ).

Currently the code of this repo only works on Android, anyone interested in iOS dev are welcome.
Currently this project is in Alpha phase, lack of GUI functionalities and creative design, containing many code for testing purpose. Please feel free to contribute!


## Screenshots:

### App:

#### Splash Screen
![Startup](/screenshots/startup.png)
#### UI
![UI](/screenshots/ui.png)

### ZeroNet:

#### Loading Screen
![Loading](/screenshots/loading.png)
#### ZeroHello
![ZeroHello](/screenshots/zerohello.png)
#### ZeroMe
![ZeroMe](http://i.imgur.com/nog7YPG.png)


## Goals:

* [ ] User-friendly installing
   - [ ] Reduce the package size by removing unused files
   - [x] Release on F-Droid, Google Play, Apple App Store and other platform's official APP market or package repository.
* [ ] Easy to use
   - [ ] Start or stop ZeroNet service by just a single tap
   - [ ] Running without killed by system
       + [x] On Android, make ZeroNet service Foreground to keep it less likely to be killed. If still killed, create 1~2 daemon services to restart ZeroNet service when it killed
   - [ ] Reduce battery and data quota ( bandwidth ) as well as data storage consuming on mobile devices. Auto-adjust the behavior of ZeroNet in different scenarios, e.g. using Wifi or cellular data, being charged or low battery. Of course, users can adjust it by themselves via GUI
   - [ ] Keep users.json and other sensitive data in internal private directory of the APP, out of other APPs' reach
   - [ ] Import master seed or users.json via GUI to let users import their ZeroNet IDs
   - [ ] GUI config of ZeroNet instead of editing zeronet.conf manually
   - [ ] Offer a thin client of ZeroNet for users' choice, working like a thin client of Bitcoin, via which users can use ZeroNet without joining as a full client, waiting large data sync, consuming much battery and data quota ( bandwidth ) as well as data storage. The thin client, holding the user's private keys, receives data from random proxies ( gateways )  and posts signed data to random proxies ( gateways ) without user's private keys leaving the user's own device

Actually, some above goals are out of the scope of this project, which means we also need to contribute to ZeroNet project itself to achieve said goals.


## Tutorial of packaging APK for ZeroNet

The packaging is not hard, thanks to Kivy's Buildozer which automates many things for us.
[The tutorial is here, which shows you in details how to do that.](./Tutorial-of-packaging-APK.md)

## Download APK

[ » Download from here](https://github.com/HelloZeroNet/ZeroNet-kivy/releases)

[ » Older releases](https://github.com/mkg20001/ZeroNet-kivy/releases)

## How to use the APK

* Be careful of your phone's firewall and permission control, let the APK go.
* If you have any problem using the web UI, you can try anther browser
* If you want to shut down ZeroNet, click ZeroHello's top-left ⋮ button and choose `shut down`
* You can update ZeroNet's source code just as you do on your PC: click ZeroHello's top-left ⋮ button, choose Version x.x.x (rev xxxx)
  - Even if it says "Already Up-To-Date" just choose it so you'll get newest dev version of ZeroNet
* You can find all the ZeroNet things and do what you want in External Storage/Android/data/net.mkg20001.zeronet/files/zero
* If you find any bug or something, go to External Storage/Android/data/net.mkg20001.zeronet/files/zero/log to see what it said in log

## Project Structure
  * src
    - zeronet.kv - Gui layout
    - main.py - Main file
    - service.py - Service file
    - platform_*.py - Platform Specific code
    * zero -  ZeroNet Source Code (if content is missing run `git submodule init --recursive`)
      - zeronet.py - ZeroNet Launcher
  * buildozer.spec - Buildozer config file with package name, title, version, android.permissions, services, etc.
