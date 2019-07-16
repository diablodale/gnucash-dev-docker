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
    PKG_BASE="git g++ cmake$(apt-cache policy cmake|grep -q 'Candidate: 2' && echo 3) ninja-build libglib2.0-dev libgtk-3-dev guile-2.0-dev libxml2-dev libxml2-utils xsltproc libxslt1-dev libicu-dev swig3.0 libwebkit2gtk-$(apt-cache policy libwebkit2gtk-4.*-dev|grep -q 'Candidate: [0-9]' && echo 4 || echo 3).*-dev" \
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
# optional forced cmake minimum version, e.g. enables debian-8 to build GnuCash 3.5-3.6 with swig3
# update-alternatives for canonical names/locations
ARG FORCE_CMAKE=3.5.1
RUN [ -z "$FORCE_CMAKE" ] || \
    if [ "$( ( (echo $FORCE_CMAKE; cmake --version | head -1 | grep -o -E '\b[0-9.]{3,}\b') | sort -V) | head -1)" != "$FORCE_CMAKE" ]; then \
        CMAKE_URL="https://cmake.org/files/v$(echo $FORCE_CMAKE | cut -d . -f -2)/cmake-${FORCE_CMAKE}-Linux-x86_64.sh" && \
        curl --silent --show-error --output ./cmake-install.sh $CMAKE_URL && \
        chmod 700 ./cmake-install.sh && \
        mkdir -p /opt/cmake && \
        ./cmake-install.sh --skip-license --exclude-subdir --prefix=/opt/cmake && \
        rm -f ./cmake-install.sh && \
        update-alternatives \
            --install /usr/local/bin/cmake  cmake  /opt/cmake/bin/cmake 20 \
            --slave   /usr/local/bin/ctest  ctest  /opt/cmake/bin/ctest \
            --slave   /usr/local/bin/cpack  cpack  /opt/cmake/bin/cpack \
            --slave   /usr/local/bin/ccmake ccmake /opt/cmake/bin/ccmake ; \
    fi && \
    git clone https://github.com/google/googletest -b release-1.8.0 gtest
ENV GTEST_ROOT=/gtest/googletest \
    GMOCK_ROOT=/gtest/googlemock

# ==== below this line, all steps are common across Linux Dockerfiles ====

# timezone, generate any needed locales, environment variables
ARG LANG=en_US.UTF-8
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    localedef -c -f UTF-8 -i en_US en_US.UTF-8 && \
    localedef -c -f UTF-8 -i en_GB en_GB.UTF-8 && \
    localedef -c -f UTF-8 -i fr_FR fr_FR.UTF-8 && \
    localedef -c -f UTF-8 -i de_DE de_DE.UTF-8 && \
    localedef -c -f UTF-8 -i $(echo "$LANG" | cut -d . -f 1) $LANG && \
    echo "LANG=${LANG}" > /etc/locale.conf
ENV BASH_ENV=~/.bashrc \
    BUILDTYPE=cmake-make \
    LANG=$LANG \
    TZ=Etc/UTC

# create python3 virtual environment
RUN python3 -m venv --system-site-packages /python3-venv

# install startup files
COPY homedir/.* /root/
COPY commonbuild ci/ctest2junit.xslt afterfailure /
RUN chmod u=rx,go= /commonbuild /afterfailure /root/.* && \
    chmod u=r,go= /ctest2junit.xslt
CMD [ "/commonbuild" ]

HEALTHCHECK --start-period=30s --interval=60s --timeout=10s \
    CMD true
