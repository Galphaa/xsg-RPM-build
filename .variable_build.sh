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

build_signed_rpm() {
    SPEC_FILE="$1"
    TARGET="$2"
    rpmbuild -bb -v --sign --clean  --target ${TARGET} ${WORKING_DIR}/rpmbuild/SPECS/${SPEC_FILE}
    #rpmbuild -bb -v ${WORKING_DIR}/rpmbuild/SPECS/${SPEC_FILE}
    #expect -exact "Enter pass phrase: "
    #send -- "blank\r"
    #expect eof
}




targ="$3"
version=`date +%Y%m%d`
release=`date +%H%M%S`


# Creating variable for future changing if needed (Dowloaded hariskon/nagios-plugins reposioty and script we need is located in nagios-plugins dirs 
nagios_plugins="nagios-plugins"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKING_DIR=`mktemp -d -p /tmp`
check_result $? "Cant create TMP Dir"

nagios_plugins=nagios-plugins



cd $WORKING_DIR


git clone --recursive https://github.com/HariSekhon/nagios-plugins.git > /dev/null 2>&1
check_result $? "Can't cloning from git repo"
   



mkdir rpmbuild
check_result $? "Can't creating rpmbuild dir"

cd rpmbuild
mkdir {BUILD,RPMS,SOURCES,SPECS,SRPMS,tmp}
check_result $? "Can't creat rpmbuilding sub dirs"

cd ../

mkdir ${WORKING_DIR}/${targ}-${version}
check_result $? "Cant create TMP Version Dir"


mkdir -p ${CURRENT_DIR}/rpmbuild/SOURCES/
check_result $? "Unable Create Source Folder"


mkdir -p ${CURRENT_DIR}/rpmbuild/SPECS/
check_result $? "Unable Create SPECS Folder"


cd $CURRENT_DIR


## copping spec files from my repo
wget https://raw.githubusercontent.com/Galphaa/xsg-RPM-build/master/file.spec > /dev/null 2>&1
check_result $? "Cant download spec file from my repo"


mv file.spec ${targ}.spec
check_result $? "Problem with renameing spec file to "$targ""


## changeed mv to cp
cp ${targ}.spec ${WORKING_DIR}/rpmbuild/SPECS/
check_result $? "Can't moving $targ Spec to rpm/SPEC/ "



cp ${targ}.spec ${CURRENT_DIR}/rpmbuild/SPECS/
check_result $? "Unable Copy RPM Config"



mkdir -p usr/lib64/nagios/plugins/
mkdir -p /usr/lib64/nagios/plugins/
cp ${WORKING_DIR}/${nagios_plugins}/${targ} usr/lib64/nagios/plugins/
cp ${WORKING_DIR}/${nagios_plugins}/${targ} /usr/lib64/nagios/plugins/



cd /usr/lib64/nagios/plugins/"${targ}-$version"
chmod -x  "${targ}"
cd -


cd usr/lib64/nagios/plugins/"${targ}-$version"
chmod -x  "${targ}"
cd -


cp -R usr $WORKING_DIR/${targ}-${version}
#cp -R etc $WORKING_DIR/${targ}-${version}



cd $WORKING_DIR

tar zcvf "${targ}-${version}".tar.gz ${targ}-${version}
check_result $? "Problem with compressing Downloaded scpript ("$targ") to tar.gz format"

## changed mv to cp
cp "${targ}-${version}".tar.gz ${CURRENT_DIR}/rpmbuild/SOURCES/
check_result $? "Unable Copy Sources"


cp ${CURRENT_DIR}/${targ}.spec ${CURRENT_DIR}/rpmbuild/SPECS/
check_result $? "Unable Copy RPM Config"


cd $CURRENT_DIR/rpmbuild

cp SOURCES/"${targ}-${version}".tar.gz "${WORKING_DIR}"/rpmbuild/SOURCES/
check_result $? "Problem with moving"



echo "Setting versions information in SPEC files"

sed -i -- "s/__NAME__/${targ}/g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec
sed -i -- "s/__VERSION__/${version}/g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec
sed -i -- "s/__RELEASE__/${release}/g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec
sed -i -- "s/__NAME__/${targ}/g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec
sed -i -- "s|__PATH__|"/usr/lib64/nagios/plugins/${targ}"|g" ${WORKING_DIR}/rpmbuild/SPECS/${targ}.spec



## changing macro to our custom rpmmacros 
cd ~

wget https://raw.githubusercontent.com/Galphaa/xsg-RPM-build/master/beta_.rpmmacros
cp .rpmmacros before_.rpmmacros

mv beta_.rpmmacros .rpmmacros
sed -i -- "s|__PATH__|${WORKING_DIR}|g" .rpmmacros
cd -

## Begining RPM building

build_signed_rpm $1 $2
check_result $? "Problem with prmbuild tool. (last section of building of RPM package)"

##moving  RPM build file to script location
 
mv ${WORKING_DIR}/rpmbuild/RPMS/x86_64/${targ}-${version}-${release}.x86_64.rpm ${CURRENT_DIR}/build/
check_result $? "Problem with moving RPM package to script file location/build directory)"


#returning old macro 

cd -
rm .rpmmacros
mv before_.rpmmacros .rpmmacros

## removing garbage and preprearing for new sesion

rm -rf $CURRENT_DIR/usr/*
rm -rf $CURRENT_DIR/usr/lib64/nagios/plugins/*
rm -f $CURRENT_DIR/${targ}.spec
rm -f $CURRENT_DIR/rpmbuild/SPECS/*
rm -f $CURRENT_DIR/rpmbuild/SOURCES/*


echo "Mission Accomplished"
