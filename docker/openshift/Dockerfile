# from https://www.drupal.org/docs/8/system-requirements/drupal-8-php-requirements
FROM php:7.4-fpm-alpine3.12

# install the PHP extensions we need
ENV MAGICK_HOME=/usr
RUN set -eux; \
	\
	apk add --no-cache --virtual .build-deps \
		coreutils \
		freetype-dev \
		libjpeg-turbo-dev \
		libpng-dev \
		libzip-dev \
    imagemagick \
    imagemagick-dev \
    autoconf \
    g++ \
    libtool \
    make \
	; \
	\
	pecl install imagick; \
  \
	docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg=/usr/include \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		pdo_mysql \
		zip \
	; \
	\
	docker-php-ext-enable imagick; \
  \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --virtual .drupal-phpexts-rundeps $runDeps; \
	apk del .build-deps

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# override memory limit and upload max filesize and post max size
# to enable bigger uploads
RUN { \
		echo 'memory_limit=512M'; \
		echo 'upload_max_filesize=32M'; \
		echo 'post_max_size=32M'; \
	} > /usr/local/etc/php/conf.d/php-overrides.ini

# Install required tools (https://docs.acquia.com/blt/install/)
# alpine-sdk required for the make script in composer.json
RUN apk update && apk upgrade && \
    apk add --no-cache git patch rsync bash mariadb-client alpine-sdk

## Install phpredis
#RUN apk --no-cache add pcre-dev ${PHPIZE_DEPS} \
#      && pecl install redis \
#      && docker-php-ext-enable redis \
#      && apk del pcre-dev ${PHPIZE_DEPS} \
#      && rm -rf /tmp/pear

# This workdir is a temporary directory for the build process:
# the files are copied to a shared volume in docker-entrypoint.sh
WORKDIR /opt/drupal

COPY / /opt/drupal
RUN chmod +x /opt/drupal/docker/openshift/docker-entrypoint.sh

# Install and run Composer
COPY --from=composer:2.0 /usr/bin/composer /usr/local/bin/
RUN set -eux; \
	export COMPOSER_HOME="$(mktemp -d)"; \
	composer install --no-progress --profile --prefer-dist --no-interaction

WORKDIR /var/www/html
ENV PATH=${PATH}:/opt/drupal/vendor/bin

# Copy start script
COPY /docker/openshift/docker-entrypoint.sh /usr/local/bin/

# Fetch certificate for the Azure MariaDB service
RUN wget https://www.digicert.com/CACerts/BaltimoreCyberTrustRoot.crt.pem -O /usr/local/share/ca-certificates/BaltimoreCyberTrustRoot.crt.pem

ENTRYPOINT ["/opt/drupal/docker/openshift/docker-entrypoint.sh"]

CMD []
