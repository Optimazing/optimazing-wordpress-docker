# 
# Installs WordPress with wp-cli (wp.cli.org) installed
# Docker Hub: https://registry.hub.docker.com/u/conetix/wordpress-with-wp-cli/
# Github Repo: https://github.com/conetix/docker-wordpress-wp-cli

# Código de https://github.com/mbovel/docker-wordpress-autoinstall/blob/master/Dockerfile

FROM php:fpm

ARG WORDPRESS_VERSION

# Add sudo in order to run wp-cli as the www-data user 
RUN apt-get update \
 && apt-get install -y libjpeg62-turbo-dev libpng-dev sudo less \
 && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
 && docker-php-ext-install gd mysqli opcache

# Install WP-CLI (http://wp-cli.org)
RUN curl -o /bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x /bin/wp

# Install dockerize (https://github.com/jwilder/dockerize)
ENV DOCKERIZE_RELEASE v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz
RUN curl -sL https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_RELEASE} \
  | tar -C /usr/bin -xzvf -

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a user to run wp-cli commands (running as root is strongly discouraged)
# @see https://github.com/wp-cli/wp-cli/pull/973#issuecomment-35842969
WORKDIR /var/www/html
RUN useradd -d /var/www/html -s /bin/bash wp \
 && chown -R wp .
USER wp

# TODO: add support for 'latest', Problem: doesn't work with `wp core verify-checksums`

# Download WordPress and verify the checksum
RUN wp core download --version=${WORDPRESS_VERSION} \
 && wp core verify-checksums --version=${WORDPRESS_VERSION}

COPY testdatawp.xml .

EXPOSE 8080

 # Configure and install WordPress
CMD wp core config \
    --dbhost=${WORDPRESS_DB_HOST} \
    --dbuser=${WORDPRESS_DB_USER} \
    --dbpass=${WORDPRESS_DB_PASSWORD} \
    --dbname=${WORDPRESS_DB_NAME} \
    --skip-check \
 # Wait for the database to be ready
    && dockerize -wait tcp://${WORDPRESS_DB_HOST} -timeout 30s \
    && wp core install \
    --url=${WORDPRESS_URL} \
    --title=${WORDPRESS_TITLE} \
    --admin_user=${WORDPRESS_ADMIN_USER} \
    --admin_password=${WORDPRESS_ADMIN_PASS} \
    --admin_email=${WORDPRESS_ADMIN_EMAIL} \
    && wp rewrite structure '/%postname%' \
    && wp plugin delete hello \
    && wp plugin install https://github.com/Automattic/amp-wp/releases/download/1.0-beta2/amp.zip --activate \
    && wp plugin install wordpress-seo --activate \
    && wp plugin install gutenberg --activate \
    && wp plugin install wordpress-importer --activate \
    && wp import testdatawp.xml --authors=skip \
    && wp theme activate optimazing \
    && wp theme delete twentyfifteen twentyseventeen twentysixteen \
    && wp option update page_on_front 701 \
    && wp server --host=0.0.0.0:8080