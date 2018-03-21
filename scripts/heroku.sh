./scripts/secret.sh \
    && echo 'HEROKU DEPLOY' \
    && heroku container:push web --app $APP_NAME
