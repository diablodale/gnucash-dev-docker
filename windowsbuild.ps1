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

# IF %GNC_IGNORE_BUILD_FAIL% NEQ 1 (
    Write-Host "GNC_IGNORE_BUILD_FAIL not yet supported"
# )

# enables minimal translation support when OS has gettext < 0.19.6
#if ! yum -q install 'gettext >= 0.19.6' &> /dev/null; then
#    export _GNC_CMAKE_COMPAT="$_GNC_CMAKE_COMPAT -DALLOW_OLD_GETTEXT=ON"
#fi

# pull updates for gnucash-on-windows; setup-mingw64.ps1 in the previous step likely persisted an old commit
C:/gcdev64/msys2/msys2_shell.cmd -defterm -no-start -c 'cd /c/gcdev64/src/gnucash-on-windows.git && git pull'

powershell
