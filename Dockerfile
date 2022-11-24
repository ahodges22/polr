FROM php:7.2-fpm-alpine

RUN apk add --update --no-cache curl-dev curl

RUN docker-php-ext-install curl pdo pdo_mysql mbstring tokenizer json

RUN apk add --update --no-cache \
    nginx supervisor && \
    mkdir /run/nginx

RUN mkdir -p /usr/src/app && chown www-data:www-data /usr/src/app/
WORKDIR /usr/src/app
COPY ./ /usr/src/app/
COPY .env.setup /usr/src/app/.env

COPY ./docker/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/supervisord.ini /etc/supervisor.d/supervisord.ini

RUN su - www-data -s /bin/ash -c 'curl -s https://getcomposer.org/installer | php'
RUN su - www-data -s /bin/ash -c 'php composer.phar install --no-dev -o -d /usr/src/app'

RUN chown www-data:www-data /usr/src/app -R

EXPOSE 8080
CMD supervisord --nodaemon --pid /var/run/supervisord.pid --configuration /etc/supervisord.conf
