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


#Write-Host "GNC_IGNORE_BUILD_FAIL not yet supported"

# enables minimal translation support when OS has gettext < 0.19.6
# if ! yum -q install 'gettext >= 0.19.6' &> /dev/null; then
#     export _GNC_CMAKE_COMPAT="$_GNC_CMAKE_COMPAT -DALLOW_OLD_GETTEXT=ON"
# fi

# view all compiler defines ==> C:/gcdev64/msys2/msys2_shell.cmd -mingw32 -defterm -no-start -c 'gcc -dM -E - < /dev/null|grep -i ming'
# for isolating build issues    C:/gcdev64/msys2/msys2_shell.cmd -mingw32 -defterm -no-start -c 'g++ -dM -E -x c++ - < /dev/null|grep -i ming'

$msys2_shell_params = @(
    '-defterm',
    '-no-start'
)
if ((! [string]::IsNullOrEmpty($Env:GNC_WINBUILDER_x86_64)) -and ($Env:GNC_WINBUILDER_x86_64.Trim() -imatch '(1|true|yes|on|enabled|64|mingw64)')) {
    $msys2_shell_params += '-mingw64'
}
else
{
    $msys2_shell_params += '-mingw32'
}

if ($Env:BUILDTYPE -ine 'stop') {
    # build GnuCash on Windows
    # BUGBUG jhbuild only supports git TARGETs of branches and tags (no commits)
    C:/gcdev64/msys2/msys2_shell.cmd @msys2_shell_params -c '[ -d "/C/gcdev64/src/gnucash-on-windows.git" ] && cd /C/gcdev64 && TARGET=gnucash-${GNC_GIT_CHECKOUT} jhbuild -f src/gnucash-on-windows.git/jhbuildrc build'
}

echo "`nCAUTION: You are at the top process of this Docker container"
echo "If you 'exit' from here, the container will stop"
echo "You can detach from the container and leave it running using the CTRL-p CTRL-q key sequence"
echo "https://docs.docker.com/engine/reference/commandline/attach/`n"
powershell.exe -NoExit
