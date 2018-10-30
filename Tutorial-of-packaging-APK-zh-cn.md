# 指导:

在Ubuntu 16.04上测试过

必需品：
 - A phone or armv7 emulator (can't build for non-arm currently)
 - Git
 - Make
 - ADB
 - Docker or Vagrant (for vagrant please skip to the bottom)

## 初始步骤
 - 首先 `git clone https://github.com/HelloZeroNet/ZeroNet-kivy --recursive`
 - 现在验证在 `src/zero` 的内容

## 安装
 - 首先，您需要生成环境配置。使用`make .env`执行此操作
 - 之后使用`make .pre`准备构建

## 建设
 - 运行`make debug`来构建应用程序的调试版本
 - 运行`make release`来构建应用程序的发布版本
 - 如果构建成功，则会显示带有ZeroNet.apk的bin文件夹
 - 运行`make run`来测试连接手机上的应用程序
   - 果您使用模拟器，请在命令后附加`ADB_FLAG=-e`

## 调试  
 - 运行 `make test` 应该启动adb logcat
 - 其他日志位于 `/storage/emulated/0/Android/data/net.mkg20001.zeronet/files/zero/log`
 - 如果`make test`不起作用，请尝试`make run`

## Vagrant
 - 首先运行 `vagrant up`
 - 这应该创建和准备虚拟机

### Building
- 运行所有命令 **inside** the vagrant VM (Use `vagrant ssh` to enter the vm)
- 测试你需要安装adb. Run `make run` or `make test` **outside** the VM
  - 如果你安装了它，运行 `make run`
  - 如果您使用模拟器，请在命令后附加 `ADB_FLAG=-e`
