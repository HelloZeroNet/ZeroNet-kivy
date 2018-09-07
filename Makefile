# Config

# Vars

TOOL=bash ./tool.sh
EXEC=$(TOOL) exec
EXEC_NAME=$(shell $(TOOL) _getvar EXEC)

# Internal

_ci:
	$(EXEC) make -C /home/data _ci_exec

_ci_exec:
	DISABLE_PROGRESS=true make _pre
	APP_ALLOW_MISSING_DEPS=true CI_MODE=1 buildozer android debug

_ci_release:
	APP_ALLOW_MISSING_DEPS=true CI_MODE=1 buildozer android release

.env:
	@echo "No .env file found..."
	@echo "Running setup..."
	$(TOOL) setup

.deps:
	make -C . $(EXEC_NAME)-deps

.pre: .env .deps
	$(TOOL) prebuild

_pre:
	python2 buildozer-android-downloader/ /home/data/buildozer.spec
	chmod +x $(HOME)/.buildozer/android/platform/android-sdk-25/tools/android
	chmod +x $(HOME)/.buildozer/android/platform/android-sdk-25/tools/bin/*
	chmod +x -R $(HOME)/.buildozer/android/platform/android-ndk-r15
	echo "y\n" | $(HOME)/.buildozer/android/platform/android-sdk-25/tools/android update sdk -u -a -t build-tools-28.0.2
	echo "y\n" | $(HOME)/.buildozer/android/platform/android-sdk-25/tools/android update sdk -u -a -t android-26
_deps: # did something, will cleanup later
	touch .deps

# Pre-targets

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
	sudo pip2 install "appdirs" "colorama>=0.3.3" sh>=1.10,\<1.12.5 "jinja2" "six"

host-deps: env _pre _deps

docker-deps:
	$(EXEC) make -C /home/data _pre _deps || (mkdir -p $(HOME)/.buildozer && sudo chmod 777 $(HOME)/.buildozer && mkdir -p $(HOME)/.gradle && sudo chmod 777 $(HOME)/.gradle && mkdir -p $(HOME)/.android/cache && sudo chmod 777 $(HOME)/.android/cache && make docker-deps)

# Targets

debug: .pre
	$(EXEC) env APP_ALLOW_MISSING_DEPS=true buildozer -v android debug

release: .pre
	$(EXEC) env APP_ALLOW_MISSING_DEPS=true buildozer -v android release

run: .pre
	adb $(ADB_FLAG) install -r bin/$(shell dir -w 1 bin | sort | tail -n 1)
	adb $(ADB_FLAG) logcat | grep "[A-Z] python\|linker\|art\|zn\|watch1\|watch2"

test: .pre
	$(EXEC) buildozer -v android deploy logcat

docker-build:
	docker build -t kivy .

release-do:
	cp -v bin/release/ZeroNet.apk $(HOME)/ZeroNet/data/1A9gZwjdcTh3bpdriaWm7Z4LNdUL8GhDu2
	cp -v bin/release/metadata.json $(HOME)/ZeroNet/data/1A9gZwjdcTh3bpdriaWm7Z4LNdUL8GhDu2

# Old targets
release-align:
	zipalign -v -p 4 $(shell find .buildozer/android/platform/build/dists/zeronet -type f -iname "ZeroNet-*-release-unsigned.apk") bin/release.apk
release-sign:
	rm -rf release bin/release
	mkdir release
	$(shell find $(ANDROID_HOME) -iname "apksigner" | sort | tac | head -n 1) sign --ks $(HOME)/.android/release --out release/ZeroNet.apk bin/release.apk
	$(shell find $(ANDROID_HOME) -iname "apksigner" | sort | tac | head -n 1) verify release/ZeroNet.apk
	mv release bin/release
	$(TOOL) metadata
update:
	if [ -e .pre ]; then rm -rf src/zero && git submodule update; fi
	git submodule foreach git pull origin master
zeroup: #update zeronet
	if [ -e .pre ]; then rm -rf src/zero && git submodule update && rm .pre; fi
	git -C src/zero remote update -p
	git -C src/zero merge --ff-only origin/master
zeroup-commit:
	git commit -m "Update ZeroNet to $(shell cat src/zero/src/Config.py | grep self.rev | head -n 1 | grep -o "[0-9]*")" src/zero
vagrant:
	vagrant up
watch: #runs on desktop
	nodemon -e kv,py,json -x /usr/bin/python2 src/main.py
clean:
	rm -fv src/*.pyc
distclean: clean
	buildozer distclean
