#!/bin/bash

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


# Usage:
#   appveyor-badge-page.sh --account <accountname>
#                          --project <projectname>
#                          --checkout <git pathspec> [--checkout <git pathspec>...]
#                          OSDIST [OSDIST...]
#
# Example:
#   appveyor-badge-page.sh --account gnucashbuilder --project gnucash-dev-docker --checkout 3.5 --checkout maint ubuntu-14.04 debian-8 centos-7
#   Creates two tables: 3.5, maint
#   Each table has three rows: ubuntu-14.04, debian-8, centos-7
#   Each row has two badges: build results, test results
#   The first table, first row, first badge will be build results for GnuCash 3.5 on Ubuntu 14.04

SHIELD='https://img.shields.io/endpoint.svg?url='
ENDPOINT='https://your.nodeservice.com/endpointpath' # no slash at end

help() {
    echo "Usage:"
    echo "  appveyor-badge-page.sh --account <accountname>"
    echo "                         --project <projectname>"
    echo "                         --checkout <git pathspec> [--checkout <git pathspec>...]"
    echo "                         OSDIST [OSDIST...]"
    echo "Example:"
    echo "  appveyor-badge-page.sh --account gnucashbuilder --project gnucash-dev-docker --checkout 3.5 --checkout maint ubuntu-14.04 debian-8 centos-7"
    echo "  Creates two tables: 3.5, maint"
    echo "  Each table has three rows: ubuntu-14.04, debian-8, centos-7"
    echo "  Each row has two badges: build results, test results"
    echo "  The first table, first row, first badge will be build results for GnuCash 3.5 on Ubuntu 14.04"
}

CHECKOUT=''
OSLIST=''
while (( "$#" )); do
    case "$1" in
        --account)
            ACCOUNT="$2"
            shift 2
            ;;
        --project)
            PROJECT="$2"
            shift 2
            ;;
        --checkout)
            CHECKOUT="$CHECKOUT $2"
            shift 2
            ;;
        --help)
            help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -* | --*)
            echo "Error: unsupported flag $1" >&2
            exit 1
            ;;
        *)
            OSLIST="$OSLIST $1"
            shift;;
    esac
done

if [[ -z "$ACCOUNT" || -z "$PROJECT" || -z "$CHECKOUT" || -z "$OSLIST" ]]; then
    echo "Error: missing parameters" >&2
    exit 1
fi

SLASH='/'
ENDPOINT="${ENDPOINT}/${ACCOUNT}/${PROJECT}/"
ENDPOINT="${ENDPOINT//$SLASH/%2F}"
ENDPOINT="${ENDPOINT//:/%3A}"
PREFIX="${SHIELD}${ENDPOINT}"
CLICK="https://ci.appveyor.com/project/${ACCOUNT}/${PROJECT}"

badge_table() {
    CHECKOUT="$1"
    shift
    echo -e "\n## $CHECKOUT\n"
    echo '| OS   | Build | Test |'
    echo '| :--- | :---  | :--- |'
    for OS in $@; do
        echo -n "|${OS}"
        echo -n "|[![${PROJECT} build](${PREFIX}build%3Fname%3D${OS}%26name%3D${CHECKOUT})](${CLICK})"
        echo    "|[![${PROJECT} tests](${PREFIX}tests%3Fname%3D${OS}%26name%3D${CHECKOUT})](${CLICK})|"
    done
}

echo "# GnuCash Build Status"

for TABLE in $CHECKOUT; do
    badge_table $TABLE $OSLIST
done
