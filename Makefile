UID=$(shell id -u)
ADB_FLAG=-d
apk:
	buildozer -v android_new debug
ci: #verbose exceeds log limit of 4mb! -.-
	sed "s/log_level = 2/log_level = 1/g" -i buildozer.spec
	DISABLE_PROGRESS=true python2 buildozer-android-downloader/ /home/data/buildozer.spec
	buildozer android_new debug
	buildozer android_new release
test:
	buildozer -v android_new deploy logcat
docker-test:
	adb $(ADB_FLAG) install -r bin/$(shell dir bin)
	adb $(ADB_FLAG) logcat | grep "[A-Z] python\|linker\|art\|zn\|watch1\|watch2"
env:
	sudo dpkg --add-architecture i386
	sudo apt-get update
	sudo apt-get install -y python2.7 python-pip software-properties-common
	sudo add-apt-repository ppa:kivy-team/kivy -y
	sudo apt-get update
	sudo apt-get install -y build-essential swig ccache git libtool pkg-config libncurses5:i386 libstdc++6:i386 libgtk2.0-0:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 python2.7 python2.7-dev openjdk-8-jdk unzip zlib1g-dev zlib1g:i386
	sudo apt-get install -y automake aidl libbz2-dev
	sudo apt-get install -y python-kivy
	sudo pip install --upgrade cython
	sudo pip install --upgrade colorama appdirs sh jinja2 six clint requests
	sudo pip install --upgrade buildozer kivy
update:
	git submodule foreach git pull origin master
prebuild:
	if [ -e .pre ]; then rm -rf src/zero && git submodule update; fi
	cd src/zero && cp src/Config.py src/Config.py_
	touch .pre
deps: #downloads sdk and ndk because buildozer is unable to download the newer ones
	python2 buildozer-android-downloader/ $(PWD)/buildozer.spec
docker-build:
	docker build -t kivy .
docker:
	[ -e .pre ] && docker run -u $(UID) --rm --privileged=true -it -v $(PWD):/home/data -v $(HOME)/.buildozer:/home/.buildozer -v $(HOME)/.android:/home/.android kivy sh -c 'echo builder:x:$(UID):27:Builder:/home:/bin/bash | tee /etc/passwd > /dev/null && make -C /home/data apk'
docker-ci:
	[ -e .pre ] && docker run -u $(UID) --rm --privileged=true -it -v $(PWD):/home/data -v $(HOME)/.buildozer:/home/.buildozer -v $(HOME)/.android:/home/.android kivy sh -c 'echo builder:x:$(UID):27:Builder:/home:/bin/bash | tee /etc/passwd && yes | make -C /home/data ci'
vagrant:
	vagrant up
watch: #runs on desktop
	nodemon -e kv,py,json -x /usr/bin/python2 src/main.py
clean:
	rm -fv src/*.pyc
distclean: clean
	buildozer distclean
