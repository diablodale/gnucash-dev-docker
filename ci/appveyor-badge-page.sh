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
#                          --project <projectslug> [--project <projectslug>...]
#                          OSDIST [OSDIST...]
#
# Example:
#   appveyor-badge-page.sh --account gnucashbuilder --project gnucash-3-5 --project gnucash-maint ubuntu-14.04 debian-8 centos-7
#   Creates two tables: 3.5, maint
#   Each table has three rows: ubuntu-14.04, debian-8, centos-7
#   Each row has two badges: build results, test results
#   The first table, first row, first badge will be build results for GnuCash 3.5 on Ubuntu 14.04

SHIELD='https://img.shields.io/endpoint.svg?url='
ENDPOINT='https://your.nodeservice.com/endpointpath' # no slash at end

help() {
    echo "Usage:"
    echo "  appveyor-badge-page.sh --account <accountname>"
    echo "                         --project <projectslug> [--project <projectslug>...]"
    echo "                         OSDIST [OSDIST...]"
    echo "Example:"
    echo "  appveyor-badge-page.sh --account gnucashbuilder --project gnucash-3-5 --project gnucash-maint ubuntu-14.04 debian-8 centos-7"
    echo "  Creates two tables: 3.5, maint"
    echo "  Each table has three rows: ubuntu-14.04, debian-8, centos-7"
    echo "  Each row has two badges: build results, test results"
    echo "  The first table, first row, first badge will be build results for GnuCash 3.5 on Ubuntu 14.04"
}

PROJECTLIST=''
OSLIST=''
while (( "$#" )); do
    case "$1" in
        --account)
            ACCOUNT="$2"
            shift 2
            ;;
        --project)
            PROJECTLIST="$PROJECTLIST $2"
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

if [[ -z "$ACCOUNT" || -z "$PROJECTLIST" || -z "$OSLIST" ]]; then
    echo "Error: missing parameters" >&2
    exit 1
fi

SLASH='/'

badge_table() {
    PROJECT="$1"
    shift
    PROJECTENDPOINT="${ENDPOINT}/${ACCOUNT}/${PROJECT}/"
    PROJECTENDPOINT="${PROJECTENDPOINT//$SLASH/%2F}"
    PROJECTENDPOINT="${PROJECTENDPOINT//:/%3A}"
    PREFIX="${SHIELD}${PROJECTENDPOINT}"
    CLICK="https://ci.appveyor.com/project/${ACCOUNT}/${PROJECT}"

    echo -e "\n## $PROJECT\n"
    echo '| OS   | Build | Test |'
    echo '| :--- | :---  | :--- |'
    for OS in $@; do
        echo -n "|${OS}"
        echo -n "|[![${PROJECT} ${OS} build](${PREFIX}build%3Fname%3D${OS})](${CLICK})"
        echo    "|[![${PROJECT} ${OS} tests](${PREFIX}tests%3Fname%3D${OS})](${CLICK})|"
    done
}

echo "# GnuCash Build Status"

for PROJECT in $PROJECTLIST; do
    badge_table $PROJECT $OSLIST
done
