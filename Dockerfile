FROM ruby:2.4.1
MAINTAINER Matt Light <matt.light@lightdatasys.com>

RUN apt-get update -qq \
    && apt install -yqq \
        git

COPY . /pier

VOLUME [ "/pier" ]
WORKDIR /pier
