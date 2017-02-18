apk:
	buildozer -v android debug
env:
	sudo dpkg --add-architecture i386
	sudo apt-get update
	sudo apt-get install -y python2.7 python-pip software-properties-common
	sudo add-apt-repository ppa:kivy-team/kivy -y
	sudo apt-get update
	sudo apt-get install -y build-essential swig ccache git libncurses5:i386 libstdc++6:i386 libgtk2.0-0:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 python2.7 python2.7-dev openjdk-8-jdk unzip zlib1g-dev zlib1g:i386
	sudo apt-get install -y python-kivy
	sudo pip install --upgrade cython==0.21
	sudo pip install --upgrade buildozer kivy
