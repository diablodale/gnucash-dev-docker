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


# supports CentOS; might support other RHEL-based distributions
ARG OS_DIST
ARG OS_TAG
FROM $OS_DIST:$OS_TAG

# volume map these to host volumes, else all source and build results will remain in container
# gnucash: contains git clone of gnucash source
# build: build destination of make
VOLUME [ "/gnucash", "/build" ]

HEALTHCHECK --start-period=30s --interval=60s --timeout=10s \
    CMD true

# setup the OS build environment; update needs to be included in installs otherwise older package database is cached in docker layer
RUN set -x; \
    yum --quiet --assumeyes install epel-release && \
    yum --quiet clean all && \
    yum --quiet makecache && \
    yum --quiet --assumeyes install yum-utils deltarpm && \
    yum --quiet --assumeyes update && \
    yum --quiet --assumeyes --exclude=swig group install 'Development Tools' && \
    yum --quiet clean all

# workaround for yum bug https://bugzilla.redhat.com/show_bug.cgi?id=1274211
RUN PKG_BASE="cmake3 glib2-devel gtk3-devel guile-devel libxml2-devel gettext-devel libxslt-devel libicu-devel boost169-devel swig3 webkitgtk4-devel" \
    PKG_BANK="aqbanking-devel" \
    PKG_DB="libdbi-devel libdbi-dbd-sqlite libdbi-dbd-mysql libdbi-dbd-pgsql" \
    PKG_OFX="libofx-devel" \
    PKG_PYTHON="python36-devel python36-gobject" \
    PKG_OTHER="iso-codes-devel dconf-devel texinfo doxygen" \
    PKG_UNDOC="libsecret-devel" \
    PKG_ALL="${PKG_BASE} ${PKG_BANK} ${PKG_DB} ${PKG_OFX} ${PKG_PYTHON} ${PKG_OTHER} ${PKG_UNDOC}"; \
    set -x; \
    for i in $PKG_ALL; do yum --quiet --assumeyes install "$i" || exit 1; done && \
    yum --quiet clean all

# map cmake3 tools to cmake* without the '3' using the update-alternatives tooling
RUN alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 \
    --slave /usr/local/bin/ctest ctest /usr/bin/ctest3 \
    --slave /usr/local/bin/cpack cpack /usr/bin/cpack3 \
    --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3 \
    --family cmake

# Gnucash 3.5+ requires Boost 1.54+
# enable Boost 1.69 from EPEL repo rather than hacking the source, e.g. http://gnucash.1415818.n4.nabble.com/GNC-GnuCash-3-3-builds-on-CentOS-7-td4704432.html
ENV BOOST_INCLUDEDIR=/usr/include/boost169
ENV _GNC_CMAKE_COMPAT="-DBoost_NAMESPACE=libboost -DBoost_COMPILER=.so.1.69.0"

# cmake requires gtest 1.8+
RUN git clone https://github.com/google/googletest -b release-1.8.0 gtest
ENV GTEST_ROOT=/gtest/googletest
ENV GMOCK_ROOT=/gtest/googlemock

# timezone, generate any needed locales
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    localedef -c -f UTF-8 -i en_US en_US.UTF-8 && \
    localedef -c -f UTF-8 -i en_GB en_GB.UTF-8 && \
    localedef -c -f UTF-8 -i fr_FR fr_FR.UTF-8 && \
    localedef -c -f UTF-8 -i de_DE de_DE.UTF-8 && \
    echo "LANG=\"${LANG:-en_US.UTF-8}\"" > /etc/locale.conf
ENV LANG=${LANG:-en_US.UTF-8}
ENV TZ=${TZ:-Etc/UTC}

# create python3 virtual environment; set bash to always configure for Python3
RUN python3 -m venv --system-site-packages /python3-venv && (echo "# activate python3 with standard venv"; echo ". /python3-venv/bin/activate") > "$HOME/.bashrc"

# environment vars
ENV BUILDTYPE=${BUILDTYPE:-cmake-make}

# install startup files
COPY commonbuild afterfailure rhelbuild /
RUN chmod u=rx,go= /commonbuild /afterfailure /rhelbuild
CMD [ "/rhelbuild" ]
