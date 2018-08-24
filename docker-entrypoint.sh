#!/bin/bash
if ! $(wp core is-installed); then
    wp core config \
        --dbhost=${WORDPRESS_DB_HOST} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${WORDPRESS_DB_PASSWORD} \
        --dbname=${WORDPRESS_DB_NAME} \
        --skip-check
    # Wait for the database to be ready
    dockerize -wait tcp://${WORDPRESS_DB_HOST} -timeout 30s
    wp core install \
        --url=${WORDPRESS_URL} \
        --title=${WORDPRESS_TITLE} \
        --admin_user=${WORDPRESS_ADMIN_USER} \
        --admin_password=${WORDPRESS_ADMIN_PASS} \
        --admin_email=${WORDPRESS_ADMIN_EMAIL}
    wp rewrite structure '/%postname%'
    wp plugin delete hello
    wp plugin install https://github.com/Automattic/amp-wp/releases/download/1.0-beta2/amp.zip --activate
    wp plugin install wordpress-seo --activate
    wp plugin install gutenberg --activate
    wp plugin install wordpress-importer --activate
    wp import testdatawp.xml --authors=skip
    wp theme activate optimazing
    wp theme delete twentyfifteen twentyseventeen twentysixteen
    wp option update page_on_front 701
fi

#Extra line added in the script to run all command line arguments
exec "$@";