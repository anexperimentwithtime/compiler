#!/bin/bash
set -e
set -o pipefail

BOOST_VERSION_DASH=$(echo $BOOST_VERSION | sed 's/\./_/g')

if [ "$BOOST_VARIANT" == "debug" ]; then
  DEBUG="on"
else
  DEBUG="off"
fi

if [ "$LINK" == "static" ]; then
  TYPE="link=static runtime-link=static"
else
  TYPE="link=shared runtime-link=shared"
fi

wget https://archives.boost.io/release/$BOOST_VERSION/source/boost_$BOOST_VERSION_DASH.tar.gz

tar -xf boost_$BOOST_VERSION_DASH.tar.gz

cd boost_$BOOST_VERSION_DASH
sh bootstrap.sh --with-libraries=all

./b2 install $TYPE $BOOST_VARIANT variant=$BOOST_VARIANT debug-symbols=$DEBUG --without-python -j 4

cd ..
rm boost_$BOOST_VERSION_DASH -rf
rm boost_$BOOST_VERSION_DASH.tar.gz
