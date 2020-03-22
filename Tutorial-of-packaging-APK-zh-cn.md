# 指导:

在Ubuntu 18.04上测试过

必需品：
 - 一个手机或者armv7模拟器（目前不能在非arm架构上build）
 - Git
 - Make
 - ADB
 - Docker or Vagrant (vagrant的话请看文章最后）

## 初始步骤
 - 首先 `git clone https://github.com/HelloZeroNet/ZeroNet-kivy --recursive`
 - 现在验证在 `src/zero` 的内容
 - （如果你clone的时候没有用`--recursive`，那么运行`git submodule init && git submodule update`）

## 搭建（Setup）

### Ｄocker (推荐)
 - 运行`make .env`。这一步会有一些问题弹出（通常你可以保持默认选项）然后再拉取docker的镜像。
 - 现在运行`setup`完成搭建

### Ｖagrant
 - 运行 `vagrant up`。这一步会创建一个ubuntu 18.04的vm并且为你执行一些必要的搭建指令
 - 注意：
   - 在vagrant VM**之内**运行所有 _building_ 指令 (使用 `vagrant ssh` 进入vm)
   - 在vagrant VM**之外**运行所有把app安装到你的手机上的指令
   - 你需要安装adb来测试. 在VM**之外**运行 `make run` 或者 `make test` 
	  - 如果你安装了它，运行 `make run`
	  - 如果您使用模拟器，请在命令后附加 `ADB_FLAG=-e`


### 本地机器
 - 运行`make .env`
	
## 生成（Building）
 - 运行`make debug`来构建应用程序的调试版本
 - 运行`make release`来构建应用程序的发布版本
 - 如果构建成功，一个含有ZeroNet.apk的bin文件夹会出现
 - 运行`make run`来测试连接手机上的应用程序
   - 果您使用模拟器，请在命令后附加`ADB_FLAG=-e`

## 调试  
 - 运行 `make test` 会启动adb logcat
 - 其他日志位于 `/storage/emulated/0/Android/data/net.mkg20001.zeronet/files/zero/log`
 - 如果`make test`不起作用，请尝试`make run`

### Building
- 运行所有命令 **inside** the vagrant VM (Use `vagrant ssh` to enter the vm)
- 你需要安装adb来测试. 运行 `make run` 或者 `make test` **outside** the VM
  - 如果你安装了它，运行 `make run`
  - 如果您使用模拟器，请在命令后附加 `ADB_FLAG=-e`
