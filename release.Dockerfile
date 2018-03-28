FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install wget -y

RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && dpkg -i erlang-solutions_1.0_all.deb

RUN apt-get update

RUN apt-get install esl-erlang -y && apt-get install elixir -y

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /

EXPOSE 4000
ENV PORT=4000 \
    VERSION=0.0.1 \
    APP=exdaas \
    MIX_ENV=prod

COPY mix.exs mix.lock ./

RUN mix do deps.get, deps.compile

COPY ./ ./

RUN apt-get install pwgen -y

RUN SECRET_KEY_BASE=$(pwgen 43 1) mix do compile, release --verbose --env=prod \
    && cp _build/prod/rel/$APP/releases/$VERSION/$APP.tar.gz $APP.tar.gz \
    && ls -lah \
    && echo "COPY FROM DOCKER NOW" \
    && echo "VERSION: $VERSION - APP: $APP"
