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


ARG OS_DISTTAG=undefined
FROM gnucashbuilder:$OS_DISTTAG

ARG GNC_EXIT_WITH_RESULT=1
ARG GNC_GIT_CHECKOUT
ARG GNC_PHASES=build,test
ARG BUILDTYPE
ARG PLATFORM_CMAKE_OPTS="-DCMAKE_INSTALL_PREFIX=/opt -DWITH_PYTHON=ON"
RUN /commonbuild
