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


# supports Arch Linux
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
RUN pacman -Syu --quiet --noconfirm --needed gcc cmake make boost python3 python-gobject pkg-config gettext guile git ninja gtest gmock sqlite3 \
           webkit2gtk swig gwenhywfar aqbanking intltool libxslt postgresql-libs libmariadbclient libdbi libdbi-drivers \
           vi tzdata > /dev/null && \
    yes | pacman -Scc ; \
    rm -rf /tmp/*

# timezone, generate locales
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    echo -e "en_US.UTF-8 UTF-8\nen_GB.UTF-8 UTF-8\nfr_FR.UTF-8 UTF-8\nde_DE.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# create python3 virtual environment; set bash to always configure for Python3
RUN python3 -m venv --system-site-packages /python3-venv && (echo "# activate python3 with standard venv"; echo ". /python3-venv/bin/activate") > "$HOME/.bashrc"

# environment vars
ENV LANG=${LANG:-en_US.UTF-8}
ENV BUILDTYPE=${BUILDTYPE:-cmake-ninja}

# install startup files
COPY commonbuild afterfailure archbuild /
RUN chmod u=rx,go= /commonbuild /afterfailure /archbuild
CMD [ "/archbuild" ]
