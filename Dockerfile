FROM ubuntu:16.04

ENV HOME /home

RUN rm -f /etc/apt/apt.conf.d/01autoremove-kernels \
 \
 #&& echo '#!/bin/sh' > /usr/sbin/policy-rc.d \
 #&& echo 'exit 101' >> /usr/sbin/policy-rc.d \
 #&& chmod +x /usr/sbin/policy-rc.d \
 #\
 #&& dpkg-divert --local --rename --add /sbin/initctl \
 #&& cp -a /usr/sbin/policy-rc.d /sbin/initctl \
 #&& sed -i 's/^exit.*/exit 0/' /sbin/initctl \
 #\
 #&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup \
 \
 && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean \
 && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean \
 && echo 'Dir::Cache::pkgcache "";' >> /etc/apt/apt.conf.d/docker-clean \
 && echo 'Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean \
 \
 && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages \
 \
 && echo 'Acquire::GzipIndexes "true";' > /etc/apt/apt.conf.d/docker-gzip-indexes \
 && echo 'Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes \
 \
 && echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests

RUN apt-get update

#Locale
RUN apt-get install language-pack-en -y
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN update-locale

RUN apt-get install -y make sudo

RUN chmod 777 /home
#This is required, fixes: KeyError: 'getpwuid(): uid not found: 1000'
RUN chmod 777 /etc/passwd

ADD Makefile .
ADD tool.sh .
RUN make -C . env

RUN rm -rfv /home
RUN mkdir /home
RUN chmod 777 /home
