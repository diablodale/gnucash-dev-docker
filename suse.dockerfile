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


# supports openSUSE; might support other SUSE-based distributions
ARG OS_DIST=opensuse/leap
ARG OS_TAG=15.0
FROM $OS_DIST:$OS_TAG

# setup the OS build environment; update needs to be included in installs otherwise older package database is cached in docker layer
RUN zypper -n refresh && \
    zypper -n patch && \
    zypper -n update && \
    PKG_BASE="git gcc gcc-c++ cmake>=3.0 ninja glib2-devel>=2.46 gtk3-devel>=3.14 guile-devel>=2.0 libxml2-devel>=2.5.10 gettext-devel>=0.19.6 libxslt-devel libicu-devel swig>=2.0.10 webkit2gtk3-devel" \
    PKG_BOOST="libboost_date_time1_66_0-devel libboost_filesystem1_66_0-devel libboost_locale1_66_0-devel libboost_regex1_66_0-devel libboost_system1_66_0-devel" \
    PKG_GTEST="gtest>=1.7 gmock>=1.7" \
    PKG_BANK="aqbanking-devel>=5.3.5 aqbanking-ofx>=5.3.5 aqbanking-ebics>=5.3.5 aqbanking-lang>=5.3.5 libgwenhywfar60-plugins" \
    PKG_DB="libdbi-devel>=0.8.3 libdbi-drivers-dbd-sqlite3>=0.8.3 libdbi-drivers-dbd-mysql>=0.8.3 libdbi-drivers-dbd-pgsql>=0.8.3" \
    PKG_OFX="libofx-devel>=0.9.0" \
    PKG_PYTHON="python3-devel>=3.2 python3-gobject" \
    PKG_OTHER="iso-codes-devel gsettings-backend-dconf texinfo doxygen gettext-runtime dbus-1-x11 timezone gzip glibc-i18ndata glibc-locale" \
    PKG_UNDOC="libsecret-devel" \
    PKG_ALL="${PKG_BASE} ${PKG_BOOST} ${PKG_GTEST} ${PKG_BANK} ${PKG_DB} ${PKG_OFX} ${PKG_PYTHON} ${PKG_OTHER} ${PKG_UNDOC}"; \
    echo $PKG_ALL | xargs zypper -n install && \
    zypper -n clean -a && \
    rm -rf /var/log/zypp /var/log/zypper.log

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
