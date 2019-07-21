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
#   azure-pipelines-badge-page.sh --account <organizationname/projectslug>
#                                 --project <pipelinename> <pipeline definitionId> [--project <pipelinename> <pipeline definitionId>]...
#                                 OSDIST [OSDIST...]
#
# Example:
#   azure-pipelines-badge-page.sh --account gnucashbuilder/gnucash-docker --project 'GnuCash 3.5' --project 'GnuCash 3.6' ubuntu-14.04 debian-8 centos-7
#   Creates two tables: 3.5, 3.6
#   Each table has three rows: ubuntu-14.04, debian-8, centos-7
#   Each row has two badges: build results, test results
#   The first table, first row, first badge will be build results for GnuCash 3.5 on Ubuntu 14.04

help() {
    echo "Usage:"
    echo "  azure-pipelines-badge-page.sh --account <organizationname/projectslug>"
    echo "                                --project <pipelinename> <pipeline definitionId> [--project <pipelinename> <pipeline definitionId>]..."
    echo "                                OSDIST [OSDIST...]"
    echo "Example:"
    echo "  azure-pipelines-badge-page.sh --account gnucashbuilder/gnucash-docker --project 'GnuCash 3.5' 2 --project 'GnuCash 3.6' 3 ubuntu-14.04 debian-8 centos-7"
    echo "  Creates two tables: 3.5, 3.6"
    echo "  Each table has three rows: ubuntu-14.04, debian-8, centos-7"
    echo "  Each row has two badges: build results, test results"
    echo "  The first table, first row, first badge will be build results for GnuCash 3.5 on Ubuntu 14.04"
}

PROJECTLIST=()
DEFIDLIST=()
OSLIST=''
while (( "$#" )); do
    case "$1" in
        --account)
            ACCOUNT="$2"
            shift 2
            ;;
        --project)
            PROJECTLIST+=("$2")
            DEFIDLIST+=("$3")
            shift 3
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
    DEFID="$2"
    shift 2
    PROJECTESC="$(echo -n "$PROJECT" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | cut -c 3-)"
    PREFIX="https://dev.azure.com/${ACCOUNT}/_apis/build/status/${PROJECTESC}?branchName=azure1&label=build&jobName=-&configuration=-%20"
    CLICK="https://dev.azure.com/${ACCOUNT}/_build/latest?definitionId=${DEFID}&branchName=azure1"
    TEST="https://img.shields.io/azure-devops/tests/${ACCOUNT}/${DEFID}/azure1.svg"

    echo -e "\n## $PROJECT\n"
    echo '| OS   | Azure Build | Azure Test |'
    echo '| :--- | :---  | :--- |'
    echo "| all  |       | [![${PROJECT} tests](${TEST})](${CLICK}) |"
    for OS in $@; do
        echo -n "|${OS}"
        OSESC="$(echo $OS | sed -e 's/\W/_/g')"
        echo -n "|[![${PROJECT} ${OS} build](${PREFIX}${OSESC})](${CLICK})"
        echo    "| ↑ |"
    done
}

echo "# GnuCash Build Status by Microsoft Azure"

for PROJECT in "${PROJECTLIST[@]}"; do
    badge_table "$PROJECT" ${DEFIDLIST[0]} $OSLIST
    DEFIDLIST=("${DEFIDLIST[@]:1}")
done
