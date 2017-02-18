FROM ubuntu:16.04

ENV HOME /home

RUN apt-get update
RUN apt-get install -y make sudo
ADD Makefile .
RUN make -C . env
