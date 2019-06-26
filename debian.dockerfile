# gnucash-dev-docker: Docker containers for automated OS setup and dev/build environ for GnuCash v3+ binaries and docs
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
ARG OS_DIST=debian
ARG OS_TAG=9
FROM $OS_DIST:$OS_TAG

# setup the OS build environment; update needs to be included in installs otherwise older apt database is cached in docker layer
RUN sed -i"" "s/^# deb-src/deb-src/" /etc/apt/sources.list && \
    (grep "^deb .*debian\.org" /etc/apt/sources.list|sed "s/^deb /deb-src /") >> /etc/apt/sources.list
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && \
    PKG_BASE="git g++ cmake$(apt-cache policy cmake|grep -q 'Candidate: 2' && echo 3) ninja-build libglib2.0-dev libgtk-3-dev guile-2.0-dev libxml2-dev xsltproc libxslt1-dev libicu-dev swig3.0 libwebkit2gtk-$(apt-cache policy libwebkit2gtk-4.*-dev|grep -q 'Candidate: [0-9]' && echo 4 || echo 3).*-dev" \
    PKG_BOOST="libboost-all-dev" \
    PKG_GTEST="" \
    PKG_BANK="libaqbanking.*-dev libgwenhywfar.*-dev libchipcard-libgwenhywfar.*-plugins" \
    PKG_DB="libdbi-dev libdbd-sqlite3 libdbd-mysql libdbd-pgsql" \
    PKG_OFX="libofx-dev" \
    PKG_PYTHON="python3-dev python3-gi ^python3(\.4)?-venv" \
    PKG_OTHER="iso-codes dconf-gsettings-backend texinfo doxygen gettext dbus-x11 tzdata locales" \
    PKG_UNDOC="libsecret-1-dev" \
    PKG_ALL="${PKG_BASE} ${PKG_BOOST} ${PKG_GTEST} ${PKG_BANK} ${PKG_DB} ${PKG_OFX} ${PKG_PYTHON} ${PKG_OTHER} ${PKG_UNDOC}"; \
    echo $PKG_ALL | xargs apt-get install -qq && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# cmake, gtest setup
# use update-alternatives to make canonical names/locations; enables swig3 on debian 8 with old cmake3
RUN update-alternatives --install /usr/local/bin/swig swig /usr/bin/swig3.0 20
ARG BUILDTYPE=cmake-make
RUN git clone https://github.com/google/googletest -b release-1.8.0 gtest
ENV GTEST_ROOT=/gtest/googletest \
    GMOCK_ROOT=/gtest/googlemock

# timezone, generate any needed locales, environment variables
ARG LANG=en_US.UTF-8
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    localedef -c -f UTF-8 -i en_US en_US.UTF-8 && \
    localedef -c -f UTF-8 -i en_GB en_GB.UTF-8 && \
    localedef -c -f UTF-8 -i fr_FR fr_FR.UTF-8 && \
    localedef -c -f UTF-8 -i de_DE de_DE.UTF-8 && \
    localedef -c -f UTF-8 -i $(echo "$LANG" | cut -d . -f 1) $LANG && \
    echo "LANG=${LANG}" > /etc/locale.conf
ARG TZ=Etc/UTC
ENV BASH_ENV=~/.bashrc \
    BUILDTYPE=$BUILDTYPE \
    LANG=$LANG \
    TZ=$TZ

# create python3 virtual environment
RUN python3 -m venv --system-site-packages /python3-venv

# install startup files
COPY homedir/.* /root/
COPY commonbuild afterfailure /
RUN chmod u=rx,go= /commonbuild /afterfailure /root/.*
CMD [ "/commonbuild" ]

# volume map these to host volumes, else all source and build results will remain in container
# gnucash: contains git clone of gnucash source
# build: build destination of make
VOLUME [ "/gnucash", "/build" ]

HEALTHCHECK --start-period=30s --interval=60s --timeout=10s \
    CMD true
