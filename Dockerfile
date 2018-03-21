FROM bitwalker/alpine-elixir:1.6.3

ARG VERSION='0.0.1'
EXPOSE 4000
ENV PORT=4000 \
  APP=exdaas \
  MIX_ENV=prod

RUN apk --update add make bash && rm -rf /var/cache/apk/*

WORKDIR ${HOME}

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY . .
RUN source .env \
  && mix do compile, release --verbose --env=prod \
  && mkdir -p /opt/$APP/log \
  && cp _build/prod/rel/$APP/releases/$VERSION/$APP.tar.gz /opt/$APP/ \
  && cd /opt/$APP \
  && tar -xzf $APP.tar.gz \
  && rm $APP.tar.gz \
  && rm -rf /opt/app/* \
  && chmod -R 777 /opt/app \
  && chmod -R 777 /opt/$APP

WORKDIR /opt/$APP

CMD ["./bin/exdaas", "foreground"]
