# ZeroNet-kivy
[简体中文](./README-zh-cn.md)
The GUI control panel and APP packaging for ZeroNet using Kivy framework
[Kivy](https://kivy.org) is an open-source cross-platform GUI framework written in Python. It works on not only Android but also iOS, even desktop (Win, Linux, Mac ). 
Currently the code of this repo only works on Android, anyone interested in iOS dev are welcome.
Currently this project is in Alpha phase, lack of GUI functionalities and creative design, containing many code for testing purpose. Please feel free to contribute!


## Goals:

* User-friendly installing
 - Reduce the package size by removing unused files
 - Release on Google Play, Apple App Store, and other platform's official APP market or package  repository.
* Easy to use
 - Start or stop ZeroNet service by just a single tap
 - Running without killed by system
   + On Android, make ZeroNet service Foreground to keep it less likely to be killed. If still killed, create 1~2 daemon services to restart ZeroNet service when it killed
 - Reduce battery and data quota ( bandwidth ) as well as data storage consuming on mobile devices. Auto-adjust the behavior of ZeroNet in different scenarios, e.g. using Wifi or cellular data, being charged or low battery. Of course, users can adjust it by themselves via GUI
 - Keep users.json and other sensitive data in internal private directory of the APP, out of other APPs' reach
 - Import master seed or users.json via GUI to let users import their ZeroNet IDs
 - GUI config of ZeroNet instead of editing zeronet.conf manually
 - Offer a thin client of ZeroNet for users' choice, working like a thin client of Bitcoin, via which users can use ZeroNet without joining as a full client, waiting large data sync, consuming much battery and data quota ( bandwidth ) as well as data storage. The thin client, holding the user's private keys, receives data from random proxies ( gateways )  and posts signed data to random proxies ( gateways ) without user's private keys leaving the user's own device

Actually, some above goals are out of the scope of this project, which means we also need to contribute to ZeroNet project itself to achieve said goals.


## Tutorial of packaging APK for ZeroNet

The packaging is not hard, thanks to Kivy's Buildozer which automates many things for us.
[The tutorial is here, which shows you in details how to do that.](./Tutorial-of-packaging-APK.md)

## Download APK

[Download from here](./dist/ZeroNet-0.2.3-debug.apk)

## How to use the APK

* Be careful of your phone's firewall and permission control, let the APK go.
* If you have any problem using the web UI, you can try anther browser
* If you wanna shut down, click ZeroHello's top-left ⋮ button, choose `shut down`
* You can update ZeroNet itself source code just as you do in PC: click ZeoHello's top-left ⋮ button, choose Version x.x.x( rev xxxx), regardless saying Up to date. Just choose it, you'll get newest dev version of ZeroNet
* You can find all the ZeroNet things and do what you want in External Storage/Android/data/package_name(e.g. android.test.myapp17)/files/zero
* If you find any bug or something, go to External Storage/Android/data/package_name(e.g. android.test.myapp17)/files/zero/log to see what it said in log

## Overview of the project structure

* zero # In which you should put whole ZeroNet source code
 - README.md
 - zeronet.py # ZeroNet source code, which will be loaded by serviceloader.py
 - ...
 - ...
* buildozer.spec #  Setting of Buildozer, you can specify package name, title, version, android.permissions, services, etc.
* DroidSansFallback.ttf # The font used by GUI, which contains Chinese words, so the font is big. But its size can be reduced by fontmin
* `inject.py_`  # Where there are major code and design. The inject.py file will be put in External Storage, so that users can inject their own code and design without root. Please inject yours! Hack it! ( the `py_` is not a typo, it is to avoid converting to pyo file while packaging )
* main.py # Entry point. It does some preparing work and execute inject.py
* README.md
* serviceloader.py # Entry point of Android Service specified in buildozer.spec, to load zero/zeronet.py as service 
