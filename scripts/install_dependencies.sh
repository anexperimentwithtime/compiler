#!/bin/bash
set -e
set -o pipefail

apk update

apk add --no-cache \
    alpine-sdk \
    cmake \
    git \
    wget \
    curl \
    bash \
    zip \
    unzip \
    tzdata \
    libtool \
    automake \
    m4 \
    re2c \
    supervisor \
    openssl-dev \
    zlib-dev \
    libcurl \
    curl-dev \
    protobuf-dev \
    python3 \
    doxygen \
    graphviz \
    rsync \
    gcovr \
    lcov \
    autoconf \
    clang-extra-tools \
    php \
    php-cli \
    php-phar \
    php-opcache \
    php-mbstring \
    php-xml \
    php-json \
    php-curl \
    php-dom \
    php-zip \
    php-intl \
    php-pdo_mysql \
    php-mysqli \
    php-tokenizer \
    php-session \
    php-xmlwriter \
    php-fileinfo \
    php-calendar \
    php-bcmath \
    php-exif \
    php-gd \
    php-gettext \
    php-iconv \
    php-openssl \
    php-posix \
    php-simplexml \
    php-sockets \
    php-sodium \
    php-xmlreader \
    mariadb-client \
    gnupg \
    binutils

if [ "$LINK" == "static" ]; then
  apk add --no-cache \
      zlib-static \
      zstd-static \
      curl-static \
      openssl-libs-static \
      nghttp2-dev \
      nghttp2-static \
      brotli-static \
      libidn2-static \
      libpsl-static \
      libunistring-static
fi

#
# Dotenv
#

if [ "$BOOST_VARIANT" == "release" ]; then
  DOTENV_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Release"
else
  DOTENV_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Debug"
fi

git clone https://github.com/laserpants/dotenv-cpp.git dotenv
cd dotenv/build
cmake .. -DBUILD_DOCS=Off $DOTENV_BUILD_ARGS
make install
cd ../..
rm dotenv -Rf

#
# Bcrypt
#

if [ "$LINK" == "static" ]; then
  BCRYPT_BUILD_ARGS="-DBUILD_SHARED_LIBS=Off"
else
  BCRYPT_BUILD_ARGS="-DBUILD_SHARED_LIBS=On"
fi

git clone https://github.com/trusch/libbcrypt.git bcrypt
cd bcrypt
mkdir build
cd build
cmake .. $BCRYPT_BUILD_ARGS
make -j4
make install
cd ../..
rm bcrypt -Rf

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer
