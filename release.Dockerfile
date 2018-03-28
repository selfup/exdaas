FROM ubuntu:16.04

ENV LANG en_US.UTF-8

RUN apt-get -qq update && apt-get -qqy install locales
RUN sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=ru_RU.UTF-8 && \
    echo "LANGUAGE=ru_RU.UTF-8" >> /etc/default/locale && \
    echo "LC_ALL=ru_RU.UTF-8" >> /etc/default/locale

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
