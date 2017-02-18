FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y make sudo
ADD Makefile .
RUN make -C . env
