FROM alpine:latest

ARG BOOST_VERSION="1.90.0"
ARG BOOST_VARIANT="release"
ARG LINK="static"

ENV TZ="UTC" \
    TERM=xterm-256color

WORKDIR /srv

COPY scripts/install_dependencies.sh install_dependencies.sh
COPY scripts/install_boost.sh install_boost.sh

RUN sh install_dependencies.sh \
    && sh install_boost.sh
