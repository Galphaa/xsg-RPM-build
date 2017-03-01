#!/usr/bin/env bash
# Prepares sources for RPM installation

PATH=$PATH:/usr/local/bin

#
# Currently Supported Operating Systems:
#wor_dir
#   CentOS 6, 7
#
# Defning return code check function


check_result() {
    if [ $1 -ne 0 ]; then
        echo "Error: $2"
        exit $1
    fi
}

build_signed_rpm() {
    SPEC_FILE=$1
    TARGET=$2
    rpmbuild -bb -v --sign --clean  --target ${TARGET} ${SPEC_FILE} 
    #expect -exact "Enter pass phrase: "
    #send -- "blank\r"
    #expect eof
}




targ="$3"
version=`date +%Y%m%d`
release=`date +%H%M%S`

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKING_DIR=`mktemp -d -p /tmp`
check_result $? "Cant create TMP Dir"


cd $WORKING_DIR
git clone --recursive https://github.com/HariSekhon/nagios-plugins.git > /dev/null 2>&1
mkdir rpmbuild
cd rpmbuild
mkdir {BUILD,RPMS,SOURCES,SPECS,SRPMS,tmp}
cd ../
mkdir $targ
## copping target file from nagios plugin folder to separet dir named by scripty name 
mv "nagios-plugins/${targ}" "${targ}/"
check_result $? "Cant coppy nagios plagin to target file"


tar zcvf ${targ}-${version}.tar.gz $targ

mv ${targ}-${version}.tar.gz rpmbuild/SOURCES/

wget https://raw.githubusercontent.com/Galphaa/xsg-RPM-build/master/file.spec > /dev/null 2>&1 ## copping spec files from my repo

mv file.spec ${targ}.spec

mv ${targ}.spec rpmbuild/SPECS/

echo "Setting versions information in SPEC files"

sed -i -- "s/__NAME__/${targ}/g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec
sed -i -- "s/__VERSION__/${version}/g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec
sed -i -- "s/__RELEASE__/${release}/g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec
sed -i -- "s/__PATH__/${WORKING_DIR}/g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec


build_signed_rpm $1 $2
mv ${WORKING_DIR}/rpmbuild/RPMS/x86_64/${targ}-${version}-${release}.x86_64.rpm ${CURRENT_DIR}/
