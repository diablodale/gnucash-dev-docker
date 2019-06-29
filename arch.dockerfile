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


# supports Arch Linux
ARG OS_DIST=archlinux/base
ARG OS_TAG=latest
FROM $OS_DIST:$OS_TAG

# setup the OS build environment; update needs to be included in installs otherwise older apt database is cached in docker layer
RUN PKG_BASE="git gcc cmake make ninja glib2 webkit2gtk guile libxslt icu swig" \
    PKG_BOOST="boost" \
    PKG_GTEST="gtest gmock" \
    PKG_BANK="aqbanking gwenhywfar" \
    PKG_DB="libdbi libdbi-drivers sqlite3 postgresql-libs libmariadbclient" \
    PKG_OFX="libofx" \
    PKG_PYTHON="python3 python-gobject" \
    PKG_OTHER="iso-codes pkg-config dconf texinfo doxygen gettext intltool tzdata" \
    PKG_UNDOC="libsecret" \
    PKG_ALL="${PKG_BASE} ${PKG_BOOST} ${PKG_GTEST} ${PKG_BANK} ${PKG_DB} ${PKG_OFX} ${PKG_PYTHON} ${PKG_OTHER} ${PKG_UNDOC}"; \
    echo $PKG_ALL | xargs pacman -Syu --quiet --noconfirm --needed > /dev/null || \
    exit 1 ; \
    yes | pacman -Scc ; \
    rm -rf /tmp/*

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
    BUILDTYPE=cmake-ninja \
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
