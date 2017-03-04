FROM ubuntu:16.04

ENV HOME /home

RUN apt-get update
RUN apt-get install -y make sudo
ADD Makefile .
RUN chmod 777 /home
#This is required, fixes: KeyError: 'getpwuid(): uid not found: 1000'
RUN chmod 777 /etc/passwd
RUN make -C . env
RUN rm -rfv /home
RUN mkdir /home
RUN chmod 777 /home
