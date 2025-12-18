# Copyright (C) 2025 Ian Torres <iantorres@outlook.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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
    libunwind-dev \
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
      libunwind-static \
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

git clone https://github.com/Zen0x7/libbcrypt.git bcrypt
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

if [ "$BOOST_VARIANT" == "release" ]; then
  if [ "$LINK" == "static" ]; then
    SPDLOG_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Release -DSPDLOG_BUILD_SHARED=OFF"
  else
    BCRYPT_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Release -DSPDLOG_BUILD_SHARED=ON"
  fi
else
  if [ "$LINK" == "static" ]; then
    SPDLOG_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Debug -DSPDLOG_BUILD_SHARED=OFF"
  else
    BCRYPT_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Debug -DSPDLOG_BUILD_SHARED=ON"
  fi
fi

git clone https://github.com/gabime/spdlog.git spdlog
cd spdlog
git checkout tags/v1.16.0
mkdir build
cd build
cmake .. $SPDLOG_BUILD_ARGS
make -j4
make install
cd ../..
rm spdlog -Rf

if [ "$BOOST_VARIANT" == "release" ]; then
  if [ "$LINK" == "static" ]; then
    SENTRY_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Release -DSENTRY_BUILD_SHARED_LIBS=OFF -DCURL_USE_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF"
  else
    SENTRY_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Release -DSENTRY_BUILD_SHARED_LIBS=ON -DCURL_USE_STATIC_LIBS=OFF -DBUILD_SHARED_LIBS=ON"
  fi
else
  if [ "$LINK" == "static" ]; then
    SENTRY_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Debug -DSENTRY_BUILD_SHARED_LIBS=OFF -DCURL_USE_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF"
  else
    SENTRY_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Debug -DSENTRY_BUILD_SHARED_LIBS=ON -DCURL_USE_STATIC_LIBS=OFF -DBUILD_SHARED_LIBS=ON"
  fi
fi

git clone https://github.com/getsentry/sentry-native.git sentry
cd sentry
git checkout tags/0.12.2
git submodule update --init --recursive
mkdir build
cd build
if [ "$LINK" == "static" ]; then
  cmake .. -DCMAKE_TOOLCHAIN_FILE=../../toolchain-static.cmake $SENTRY_BUILD_ARGS -DSENTRY_BACKEND=crashpad -DSENTRY_BUILD_TESTS=OFF -DSENTRY_BUILD_EXAMPLES=OFF
else
  cmake .. $SENTRY_BUILD_ARGS -DSENTRY_BACKEND=crashpad -DSENTRY_BUILD_TESTS=OFF -DSENTRY_BUILD_EXAMPLES=OFF
fi
make -j4
make install
cd ../..
rm sentry -Rf

if [ "$BOOST_VARIANT" == "release" ]; then
  if [ "$LINK" == "static" ]; then
    FMT_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF"
  else
    FMT_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON"
  fi
else
  if [ "$LINK" == "static" ]; then
    FMT_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Debug -DBUILD_SHARED_LIBS=OFF"
  else
    FMT_BUILD_ARGS="-DCMAKE_BUILD_TYPE=Debug -DBUILD_SHARED_LIBS=ON"
  fi
fi

git clone https://github.com/fmtlib/fmt.git fmt
cd fmt
git checkout tags/12.1.0
mkdir build
cd build
cmake .. $FMT_BUILD_ARGS -DFMT_DOC=OFF -DFMT_TEST=OFF -DFMT_FUZZ=OFF -DFMT_CUDA_TEST=OFF
make -j4
make install
cd ../..
rm fmt -Rf

