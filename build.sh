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
    SPEC_FILE="$1"
    TARGET="$2"
    #rpmbuild -bb -v --sign --clean  --target ${TARGET} ${WORKING_DIR}/rpmbuild/SPECS/${SPEC_FILE}
    rpmbuild -bb -v ${WORKING_DIR}/rpmbuild/SPECS/${SPEC_FILE}
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
check_result $? "Can't cloning from git repo"

mkdir rpmbuild
check_result $? "Can't creating rpmbuild dir"

cd rpmbuild
mkdir {BUILD,RPMS,SOURCES,SPECS,SRPMS,tmp}
check_result $? "Can't creat rpmbuilding sub dirs"

## copping target file from nagios plugin folder to separet dir named by scripty name 

cd ../
mkdir ${targ}-${version}
check_result $? "Creating $targ directory with version tag"

mv "nagios-plugins/${targ}" "${targ}-${version}/"
check_result $? "Cant coppy nagios plagin to target file"

tar zcvf "${targ}-${version}.tar.gz" "${targ}-${version}"
check_result $? "Problem with compressing Downloaded scpript ("$targ") to tar.gz format"

mv "${targ}-${version}.tar.gz" "rpmbuild/SOURCES/"
check_result $? "Problem with moving"

## copping spec files from my repo
wget https://raw.githubusercontent.com/Galphaa/xsg-RPM-build/master/file.spec > /dev/null 2>&1 
check_result $? "Cant download spec file from my repo"


mv file.spec ${targ}.spec
check_result $? "Problem with renameing spec file to "$targ""

mv ${targ}.spec rpmbuild/SPECS/
check_result $? "Can't moving $targ Spec to rpm/SPEC/ "



echo "Setting versions information in SPEC files"

sed -i -- "s/__NAME__/${targ}/g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec
sed -i -- "s/__VERSION__/${version}/g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec
sed -i -- "s/__RELEASE__/${release}/g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec
sed -i -- "s|__PATH__|${WORKING_DIR}|g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec

cd ~
wget https://raw.githubusercontent.com/Galphaa/xsg-RPM-build/master/beta_.rpmmacros
cp .rpmmacros before_.rpmmacros
mv beta_.rpmmacros .rpmmacros
sed -i -- "s|__PATH__|${WORKING_DIR}|g" .rpmmacros
cd -

## Begining RPM building 
build_signed_rpm $1 $2

mv ${WORKING_DIR}/rpmbuild/RPMS/x86_64/${targ}-${version}-${release}.x86_64.rpm ${CURRENT_DIR}/build/
check_result $? "Problem with prmbuild tool. (last section of building of RPM package)"
cd - 
rm .rpmmacros 
mv before_.rpmmacros .rpmmacros




echo "Good job men :)))"
