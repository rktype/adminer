FROM webdevops/php-nginx:8.3-alpine
ARG ADMINER_VERSION=4.17.2
ARG PEMATON_THEME_VERSION=1.8.2

ENV SERVICE_NGINX_CLIENT_MAX_BODY_SIZE=512M
ENV PHP_POST_MAX_SIZE=512M
ENV PHP_UPLOAD_MAX_FILESIZE=512M
ENV PHP_MEMORY_LIMIT=2G

# Install dependencies
RUN apk add --update --no-cache \
    php82-dev \
    make \
    gcc \
    g++ \
    unixodbc-dev \
    curl \
    gnupg \
    # Cleanup
    && rm -rf /var/cache/apk/*

#Download mssql package(s)
RUN curl -O https://download.microsoft.com/download/3/5/5/355d7943-a338-41a7-858d-53b259ea33f5/msodbcsql18_18.3.3.1-1_amd64.apk \
    && curl -O https://download.microsoft.com/download/3/5/5/355d7943-a338-41a7-858d-53b259ea33f5/mssql-tools18_18.3.1.1-1_amd64.apk \
    #
    # (Optional) Verify signature, if 'gpg' is missing install it using 'apk add gnupg':
    && curl -O https://download.microsoft.com/download/3/5/5/355d7943-a338-41a7-858d-53b259ea33f5/msodbcsql18_18.3.3.1-1_amd64.sig \
    && curl -O https://download.microsoft.com/download/3/5/5/355d7943-a338-41a7-858d-53b259ea33f5/mssql-tools18_18.3.1.1-1_amd64.sig \
    #
    && curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - \
    && gpg --verify msodbcsql18_18.3.3.1-1_amd64.sig msodbcsql18_18.3.3.1-1_amd64.apk \
    && gpg --verify mssql-tools18_18.3.1.1-1_amd64.sig mssql-tools18_18.3.1.1-1_amd64.apk \
    #
    #Install the package(s)
    && apk add --allow-untrusted msodbcsql18_18.3.3.1-1_amd64.apk \
        mssql-tools18_18.3.1.1-1_amd64.apk \
    && rm msodbcsql18_18.3.3.1-1_amd64.apk \
    && rm mssql-tools18_18.3.1.1-1_amd64.apk

# install pdo_odbc
RUN pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv

# Moving default port from 80 to 8080
RUN sed -i 's/listen 80/listen 8080/g' /opt/docker/etc/nginx/vhost.conf \
    && sed -i 's/listen \[::\]:80/listen \[::\]:8080/g' /opt/docker/etc/nginx/vhost.conf

# Installing Adminer and theme
RUN wget https://github.com/adminerneo/adminerneo/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php -O /app/adminer.php \
    # Pematon theme
    && wget https://github.com/pematon/adminer-theme/archive/refs/tags/v${PEMATON_THEME_VERSION}.tar.gz -O /tmp/adminer-theme.tar.gz \
    && tar -xf /tmp/adminer-theme.tar.gz -C /tmp \
    && cp -R /tmp/adminer-theme-${PEMATON_THEME_VERSION}/lib/* /app/ \
    # Adminer plugin file
    && wget https://github.com/adminerneo/adminerneo/archive/refs/tags/v${ADMINER_VERSION}.tar.gz -O /tmp/adminer.tar.gz \
    && tar -xf /tmp/adminer.tar.gz -C /tmp \
    # Importing plugin
    && cp /tmp/adminneo-${ADMINER_VERSION}/plugins/plugin.php /app/plugins/plugin.php \
    && cp /tmp/adminneo-${ADMINER_VERSION}/plugins/login-ssl.php /app/plugins/login-ssl.php \
    # Cleanup
    && rm -rf /tmp/*

# Copying index.php
COPY ./index.php /app/index.php

EXPOSE 8080