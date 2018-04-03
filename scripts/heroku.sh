./scripts/secret.sh \
    && echo '--->' \
    && echo 'HEROKU DEPLOY' \
    && echo '--->' \
    && heroku container:push web --app $APP_NAME
