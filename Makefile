UID=$(shell id -u)
apk:
	buildozer -v android_new debug
ci: #verbose exceeds log limit of 4mb! -.-
	sed "s/log_level = 2/log_level = 1/g" -i buildozer.spec
	buildozer android_new debug
test:
	buildozer -v android_new deploy logcat
env:
	sudo dpkg --add-architecture i386
	sudo apt-get update
	sudo apt-get install -y python2.7 python-pip software-properties-common
	sudo add-apt-repository ppa:kivy-team/kivy -y
	sudo apt-get update
	sudo apt-get install -y build-essential swig ccache git libncurses5:i386 libstdc++6:i386 libgtk2.0-0:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 python2.7 python2.7-dev openjdk-8-jdk unzip zlib1g-dev zlib1g:i386
	sudo apt-get install -y automake aidl
	sudo apt-get install -y python-kivy
	sudo pip install --upgrade cython==0.21
	sudo pip install --upgrade colorama appdirs sh jinja2 six
	sudo pip install --upgrade buildozer kivy
docker-build:
	docker build -t kivy .
docker:
	docker run -u $(UID) --rm --privileged=true -it -v $(PWD):/home/data -v $(HOME)/.buildozer:/home/.buildozer kivy sh -c 'echo builder:x:$(UID):27:Builder:/home:/bin/bash | tee /etc/passwd > /dev/null && make -C /home/data apk'
docker-ci:
	docker run -u $(UID) --rm --privileged=true -it -v $(PWD):/home/data kivy sh -c 'echo builder:x:$(UID):27:Builder:/home:/bin/bash | tee /etc/passwd && yes | make -C /home/data ci'
vagrant:
	vagrant up
