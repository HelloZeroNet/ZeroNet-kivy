FROM ubuntu:16.04

ENV /home

RUN apt-get update
RUN apt-get install -y make sudo
ADD Makefile .
RUN make -C . env
