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

FROM alpine:latest

ARG BOOST_VERSION="1.90.0"
ARG BOOST_VARIANT="release"
ARG LINK="static"

ENV TZ="UTC" \
    TERM=xterm-256color

WORKDIR /srv

COPY scripts/install_dependencies.sh install_dependencies.sh
COPY scripts/install_boost.sh install_boost.sh

COPY LICENSE .

RUN sh install_dependencies.sh \
    && sh install_boost.sh
