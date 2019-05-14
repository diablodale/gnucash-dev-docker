# gnucash-dev-docker: Docker containers for automated OS setup and dev/build environ for gnucash v3+ binaries and docs
# Copyright (C) 2019 Dale Phurrough <dale@hidale.com>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


# supports Debian, Ubuntu; might support other debian-based distributions
ARG OS_DIST
ARG OS_TAG
FROM $OS_DIST:$OS_TAG

# volume map these to host volumes, else all source and build results will remain in container
# gnucash: contains git clone of gnucash source
# build: build destination of make
VOLUME [ "/gnucash", "/build" ]

HEALTHCHECK --start-period=30s --interval=60s --timeout=10s \
    CMD true

# setup the OS build environment; update needs to be included in installs otherwise older apt database is cached in docker layer
RUN sed -i"" "s/^# deb-src/deb-src/" /etc/apt/sources.list && \
    (grep "^deb .*debian\.org" /etc/apt/sources.list|sed "s/^deb /deb-src /") >> /etc/apt/sources.list
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && \
    apt-get build-dep -qq gnucash > /dev/null && \
    apt-get install -qq tzdata git bash-completion make swig xsltproc texinfo ninja-build libboost-all-dev libgtk-3-dev \
            aqbanking-tools libdbd-sqlite3 libdbd-pgsql libdbd-mysql locales dbus-x11 \
            $(apt-cache policy locales-all|grep -q "Candidate: [0-9]" && echo "locales-all") \
            cmake$(apt-cache policy cmake|grep -q "Candidate: 2" && echo 3) \
            libwebkit2gtk-$(apt-cache policy libwebkit2gtk-4.0|grep -q "Candidate: [0-9]" && echo 4 || echo 3).0-dev > /dev/null && \
    # why (re)install these two specific language-packs on Ubuntu? Perhaps parameterize locales with ARG
    (apt-cache policy language-pack-en|grep -q "Candidate:" && apt-get --reinstall install -qq language-pack-en language-pack-fr > /dev/null || exit 0) && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# cmake requires gtest
RUN git clone https://github.com/google/googletest -b release-1.8.0 gtest

# environment vars
RUN update-locale LANG=${LANG:-en_US.UTF-8}
ENV LANG=${LANG:-en_US.UTF-8}
ENV GTEST_ROOT=/gtest/googletest
ENV GMOCK_ROOT=/gtest/googlemock
ENV BUILDTYPE=${BUILDTYPE:-cmake-make}

# install startup files
COPY commonbuild afterfailure debianbuild /
RUN chmod u=rx,go= /commonbuild /afterfailure /debianbuild
CMD [ "/debianbuild" ]
