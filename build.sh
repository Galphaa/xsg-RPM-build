#!/usr/bin/env bash
# Prepares sources for RPM installation

PATH=$PATH:/usr/local/bin

#
# Currently Supported Operating Systems:
#
#   CentOS 6, 7
#
# Defning return code check function
check_result() {
    if [ $1 -ne 0 ]; then
        echo "Error: $2"
        exit $1
    fi
}

version=`date +%Y%m%d`
release=`date +%H%M%S`

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKING_DIR=`mktemp -d -p /tmp`
check_result $? "Cant create TMP Dir"

cd $WORKING_DIR
git clone --recursive https://github.com/HariSekhon/nagios-plugins.git


