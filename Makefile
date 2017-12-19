#Config

UID=$(shell id -u)
ADB_FLAG=-d
VER_SUFFIX=1

#Targets
apk:
	buildozer -v android debug
release-sign:
	rm -rf _bin
	[ -e bin ] && mv bin _bin || mkdir bin
	rm -rf _bin/release
	mkdir -p bin _bin
	zipalign -v -p 4 $(shell find .buildozer/android/platform/build/dists/zeronet -type f -iname "ZeroNet-*-release-unsigned.apk") bin/release.apk
	$(shell find $(ANDROID_HOME) -iname "apksigner" | sort | tac | head -n 1) sign --ks $(HOME)/.android/release --out bin/ZeroNet.apk bin/release.apk
	$(shell find $(ANDROID_HOME) -iname "apksigner" | sort | tac | head -n 1) verify bin/ZeroNet.apk
	mv bin _bin/release
	mv _bin bin
release:
	make docker-exec ARGS="android release"
	make release-sign
ci:
	DISABLE_PROGRESS=true python2 buildozer-android-downloader/ /home/data/buildozer.spec
	chmod +x $(HOME)/.buildozer/android/platform/android-sdk-25/tools/android
	echo "y\n" | $(HOME)/.buildozer/android/platform/android-sdk-25/tools/android update sdk -u -a -t build-tools-25.0.4
	CI_MODE=1 buildozer android debug
	#CI_MODE=1 buildozer android release
test:
	buildozer -v android deploy logcat
docker-test:
	adb $(ADB_FLAG) install -r bin/$(shell dir -w 1 bin | sort | tail -n 1)
	adb $(ADB_FLAG) logcat | grep "[A-Z] python\|linker\|art\|zn\|watch1\|watch2"
env:
	sudo dpkg --add-architecture i386
	sudo apt-get update
	sudo apt-get install -y python2.7 python-pip software-properties-common
	sudo apt-get install -y mesa-common-dev libgl1-mesa-dev libglu1-mesa-dev
	sudo add-apt-repository ppa:kivy-team/kivy -y
	sudo apt-get update
	sudo apt-get install -y build-essential swig ccache git libtool pkg-config libncurses5:i386 libstdc++6:i386 libgtk2.0-0:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 python2.7 python2.7-dev openjdk-8-jdk unzip zlib1g-dev zlib1g:i386
	sudo apt-get install -y automake aidl libbz2-dev
	sudo apt-get install -y python-kivy
	sudo pip2 install --upgrade "cython == 0.25"
	sudo pip2 install --upgrade colorama appdirs sh>=1.10,\<1.12.5 jinja2 six clint requests
	sudo pip2 install --upgrade git+https://github.com/mkg20001/buildozer kivy
	sudo pip2 install "appdirs" "colorama>=0.3.3" "sh>=1.10,<1.12.5" "jinja2" "six"
update:
	if [ -e .pre ]; then rm -rf src/zero && git submodule update; fi
	git submodule foreach git pull origin master
zeroup: #update zeronet
	if [ -e .pre ]; then rm -rf src/zero && git submodule update && rm .pre; fi
	git remote update -p
	git merge --ff-only origin/master
prebuild:
	if [ -e .pre ]; then rm -rf src/zero && git submodule update; fi
	cd src/zero && cp src/Config.py src/Config.py_ && sed -r "s|self\.version = ['\"](.*)['\"]|self.version = \"\1.$(VER_SUFFIX)\"|g" -i src/Config.py
	touch .pre
pre:
	python2 buildozer-android-downloader/ /home/data/buildozer.spec
	chmod +x $(HOME)/.buildozer/android/platform/android-sdk-25/tools/android
	echo "y\n" | $(HOME)/.buildozer/android/platform/android-sdk-25/tools/android update sdk -u -a -t build-tools-25.0.2
deps: #downloads sdk and ndk because buildozer is unable to download the newer ones
	python2 buildozer-android-downloader/ $(PWD)/buildozer.spec
docker-build:
	docker build -t kivy .
docker:
	[ -e .pre ] && docker run -u $(UID) --rm --privileged=true -it -v $(PWD):/home/data -v $(HOME)/.buildozer:/home/.buildozer -v $(HOME)/.android:/home/.android kivy sh -c 'echo builder:x:$(UID):27:Builder:/home:/bin/bash | tee /etc/passwd > /dev/null && make -C /home/data apk'
docker-exec:
	[ -e .pre ] && docker run -u $(UID) --rm --privileged=true -it -v $(PWD):/home/data -v $(HOME)/.buildozer:/home/.buildozer -v $(HOME)/.android:/home/.android kivy sh -c 'echo builder:x:$(UID):27:Builder:/home:/bin/bash | tee /etc/passwd > /dev/null && cd /home/data && buildozer $(ARGS)'
docker-ci:
	[ -e .pre ] && docker run -u $(UID) --rm --privileged=true -it -v $(PWD):/home/data -v $(HOME)/.buildozer:/home/.buildozer -v $(HOME)/.android:/home/.android kivy sh -c 'echo builder:x:$(UID):27:Builder:/home:/bin/bash | tee /etc/passwd && yes | make -C /home/data ci'
docker-pre:
	[ -e .pre ] && docker run -u $(UID) --rm --privileged=true -it -v $(PWD):/home/data -v $(HOME)/.buildozer:/home/.buildozer -v $(HOME)/.android:/home/.android kivy sh -c 'echo builder:x:$(UID):27:Builder:/home:/bin/bash | tee /etc/passwd > /dev/null && make -C /home/data pre' || (mkdir -p $(HOME)/.buildozer && sudo chmod 777 $(HOME)/.buildozer && make docker-pre)
vagrant:
	vagrant up
watch: #runs on desktop
	nodemon -e kv,py,json -x /usr/bin/python2 src/main.py
clean:
	rm -fv src/*.pyc
distclean: clean
	buildozer distclean
