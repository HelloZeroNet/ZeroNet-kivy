# Config

# Vars

TOOL=bash ./tool.sh
EXEC=$(TOOL) exec
EXEC_NAME=$(shell $(TOOL) _getvar EXEC)

# Continuous Integration (gitlab-ci)

_ci: # Wrapper
	$(EXEC) make -C /home/data _ci_exec

_ci_exec: # Actual commands
	APP_ALLOW_MISSING_DEPS=true CI_MODE=1 CI=1 buildozer android debug
	APP_ALLOW_MISSING_DEPS=true CI_MODE=1 CI=1 buildozer android release

# Setup

env:
	sudo dpkg --add-architecture i386
	sudo apt-get update
	sudo apt-get install -y python2.7 python-pip software-properties-common python3 python3-dev python-dev
	sudo apt-get install -y mesa-common-dev libgl1-mesa-dev libglu1-mesa-dev zip
	sudo add-apt-repository ppa:kivy-team/kivy -y
	sudo apt-get update
	sudo apt-get install -y build-essential cmake swig ccache git libtool pkg-config libncurses5:i386 libstdc++6:i386 libgtk2.0-0:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 python2.7 python2.7-dev openjdk-8-jdk unzip zlib1g-dev zlib1g:i386
	sudo apt-get install -y automake aidl libbz2-dev libffi-dev
	sudo apt-get install -y python-kivy
	sudo pip2 install --upgrade "cython == 0.25"
	sudo pip2 install --upgrade colorama appdirs 'sh>=1.10,<1.12.5' jinja2 six clint requests
	sudo pip2 install --upgrade git+https://github.com/mkg20001/buildozer kivy
	sudo pip2 install "appdirs" "colorama>=0.3.3" 'sh>=1.10,<1.12.5' "jinja2" "six"

# Targets for setup

setup: .pre
.env:
	@echo "No .env file found..."
	@echo "Running setup..."
	$(TOOL) setup

.pre: .env .deps

# Targets for specific build modes

.deps:
	make -C . $(EXEC_NAME)-deps
	touch .deps

host-deps: prebuild

docker-deps:
	# TODO: rethink below cmd
	mkdir -p $(HOME)/.buildozer && sudo chmod 777 $(HOME)/.buildozer && mkdir -p $(HOME)/.gradle && sudo chmod 777 $(HOME)/.gradle && mkdir -p $(HOME)/.android/cache && sudo chmod 777 $(HOME)/.android/cache
	$(EXEC) make -C /home/data prebuild # Launch in wrapper

docker-build:
	docker build -t kivy .

# Actual Targets

debug: .pre
	$(EXEC) env APP_ALLOW_MISSING_DEPS=true buildozer -v android debug

release: .pre
	$(EXEC) env APP_ALLOW_MISSING_DEPS=true buildozer -v android release

run: .pre
	adb $(ADB_FLAG) install -r bin/$(shell dir -w 1 bin | sort | tail -n 1)
	adb $(ADB_FLAG) logcat | grep "[A-Z] python\|linker\|art\|zn\|watch1\|watch2"

test: .pre
	$(EXEC) buildozer -v android deploy logcat

prebuild: .env
	$(TOOL) prebuild

# Old targets (will be replaced by automated scripts later)
release-do:
	cp -v bin/release/ZeroNet.apk $(HOME)/ZeroNet/data/1A9gZwjdcTh3bpdriaWm7Z4LNdUL8GhDu2
	cp -v bin/release/metadata.json $(HOME)/ZeroNet/data/1A9gZwjdcTh3bpdriaWm7Z4LNdUL8GhDu2
release-align:
	rm -f bin/release.apk
	zipalign -v -p 4 $(shell find bin -type f -iname "*-release-unsigned.apk") bin/release.apk
release-sign:
	rm -rf release bin/release
	mkdir release
	$(shell find $(ANDROID_HOME) -iname "apksigner" | sort | tac | head -n 1) sign --ks $(HOME)/.android/release --out release/ZeroNet.apk bin/release.apk
	$(shell find $(ANDROID_HOME) -iname "apksigner" | sort | tac | head -n 1) verify release/ZeroNet.apk
	mv release bin/release
	$(TOOL) metadata
watch: #runs on desktop
	nodemon -e kv,py,json -x /usr/bin/python2 src/main.py
