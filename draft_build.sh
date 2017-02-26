#!/bin/bash
# Prepares sources for RPM installation

PATH=$PATH:/usr/local/bin

#
# Currently Supported Operating Systems:
#
#   CentOS 5, 6, 7
#

# Defning return code check function
check_result() {
    if [ $1 -ne 0 ]; then
        echo "Error: $2"
        exit $1
    fi
}

help() {
    echo "Usage: $0 [OPTIONS]
  -n, --nginx             NGINX Version
  -p, --php               PHP Version
  -h, --help              Print this help

  Example: bash $0 -v 123"
    exit 1
}

#compile_bash_file() {
#    FILE_TO_CHECK=$1
#
#    INTERPRETER=`head -n 1 $FILE_TO_CHECK`
#
#    if [ "$INTERPRETER" == "#!/bin/bash" ]; then
#        shc -f $FILE_TO_CHECK
#        check_result $? "Failed to Compile"
#        mv ${FILE_TO_CHECK}.x ${FILE_TO_CHECK}
#        check_result $? "Failed to rename"
#        rm ${FILE_TO_CHECK}.x.c
#        check_result $? "Failed to Remove Extra Files"
#    fi
#}

build_signed_rpm() {
    SPEC_FILE=$1
    TARGET=$2
    rpmbuild -bb -v --sign --clean  --target ${TARGET} rpmbuild/SPECS/${SPEC_FILE} > /dev/null 2>&1
    check_result $? "Failed to Build $1"
    #expect -exact "Enter pass phrase: "
    #send -- "blank\r"
    #expect eof
}

# Translating argument to --gnu-long-options
for arg; do
    delim=""
    case "$arg" in
        --nginx)                args="${args}-n " ;;
        --php)                  args="${args}-p " ;;
        --help)                 args="${args}-h " ;;
        *)                      [[ "${arg:0:1}" == "-" ]] || delim="\""
                                args="${args}${delim}${arg}${delim} ";;
    esac
done
eval set -- "$args"

# Parsing arguments
while getopts "n:p:fh" Option; do
    case $Option in
        n) nginx=$OPTARG ;;             # NGINX
        p) php=$OPTARG ;;               # PHP
        h) help ;;                      # Help
        *) help ;;                      # Print help (default)
    esac
done

if [ -z "$php" ]
then
    help
fi

if [ -z "$nginx" ]
then
    help
fi

version=`date +%Y%m%d`
release=`date +%H%M%S`

#    
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKING_DIR=`mktemp -d -p /tmp`
check_result $? "Cant create TMP Dir"

echo "Creating Working Dir Structure..."

# Vesta- source-
mkdir ${WORKING_DIR}/vesta-${version}
check_result $? "Cant create TMP Version Dir"

# rpmbuild 
mkdir -p ${CURRENT_DIR}/rpmbuild/SOURCES/
check_result $? "Unable Create Source Folder"

mkdir -p ${CURRENT_DIR}/rpmbuild/SPECS/
check_result $? "Unable Create SPECS Folder"

cd ${CURRENT_DIR}

echo "Applying Paches..."

#  Patch-
for PATCH in ./patches/*.patch
do
  patch -p0 < ${PATCH}
  check_result $? "Failed to apply patch: ${PATCH}"
done

echo "Preparing Vesta Sources"

cp -R bin $WORKING_DIR/vesta-${version}
cp -R func $WORKING_DIR/vesta-${version}
cp -R test $WORKING_DIR/vesta-${version}
cp -R upd $WORKING_DIR/vesta-${version}
cp -R web $WORKING_DIR/vesta-${version}

#cd $WORKING_DIR/vesta-${version}

#SHC_SOURCE_DIR=$WORKING_DIR/vesta-${version}/bin/*

#for FILE_TO_CHECK in $SHC_SOURCE_DIR
#do
#    compile_bash_file $FILE_TO_CHECK
#done

cd $WORKING_DIR

tar zcvf "vesta-${version}.tar.gz" vesta-${version} > /dev/null 2>&1
check_result $? "Unable Create Archive"

mv "vesta-${version}.tar.gz" ${CURRENT_DIR}/rpmbuild/SOURCES/
check_result $? "Unable Copy Vesta Sources"

echo "Preparing Vesta-PHP Sources"

cd $WORKING_DIR

PHP_URL="http://php.net/get/php-${php}.tar.gz/from/this/mirror"

wget $PHP_URL -O "php-${php}.tar.gz" > /dev/null 2>&1
check_result $? "Unable Downloand PHP Version"

tar zxvf "php-${php}.tar.gz" > /dev/null 2>&1
check_result $? "Unable Extract PHP"

rm -f "php-${php}.tar.gz"
mv "php-${php}" "vesta-php-${version}"
check_result $? "Unable Compare PHP"

tar zcvf "vesta-php-${version}.tar.gz" "vesta-php-${version}" > /dev/null 2>&1
check_result $? "Unable Create Vesta-PHP Source"

mv "vesta-php-${version}.tar.gz" ${CURRENT_DIR}/rpmbuild/SOURCES/
check_result $? "Unable Copy Vesta-PHP Sources"

echo "Preparing Vesta-NGINX Sources"

NGINX_URL="https://nginx.org/download/nginx-${nginx}.tar.gz"

wget $NGINX_URL -O "nginx-${nginx}.tar.gz" > /dev/null 2>&1
check_result $? "Unable Downloand NGINX Version"

tar zxvf "nginx-${nginx}.tar.gz" > /dev/null 2>&1
check_result $? "Unable Extract NGINX"

rm -f "nginx-${nginx}.tar.gz"
mv "nginx-${nginx}" "vesta-nginx-${version}" > /dev/null 2>&1
check_result $? "Unable Compare NGINX"

tar zcvf "vesta-nginx-${version}.tar.gz" "vesta-nginx-${version}" > /dev/null 2>&1
check_result $? "Unable Create Vesta-NGINX Source"

mv "vesta-nginx-${version}.tar.gz" ${CURRENT_DIR}/rpmbuild/SOURCES/
check_result $? "Unable Copy Vesta-NGINX Sources"

echo "Copying extra source files from current source tree"

cd $CURRENT_DIR
cp ./src/rpm/conf/nginx.conf ${CURRENT_DIR}/rpmbuild/SOURCES/
check_result $? "Unable Copy NGINX Config"

cp ./src/rpm/conf/php.ini ${CURRENT_DIR}/rpmbuild/SOURCES/
check_result $? "Unable Copy PHP Config"

cp ./src/rpm/conf/php-fpm.conf ${CURRENT_DIR}/rpmbuild/SOURCES/
check_result $? "Unable Copy PHP-FPM Config"

cp ./src/rpm/conf/vesta.init ${CURRENT_DIR}/rpmbuild/SOURCES/
check_result $? "Unable Copy VestaCP Service Config"

cp ./src/rpm/specs/vesta.spec ${CURRENT_DIR}/rpmbuild/SPECS/
check_result $? "Unable Copy VestaCP RPM Config"

cp ./src/rpm/specs/vesta-php.spec ${CURRENT_DIR}/rpmbuild/SPECS/
check_result $? "Unable Copy VestaCP-PHP RPM Config"

cp ./src/rpm/specs/vesta-nginx.spec ${CURRENT_DIR}/rpmbuild/SPECS/
check_result $? "Unable Copy VestaCP-NGINX RPM Config"

echo "Setting versions information in SPEC files"

sed -i -- "s/__VERSION__/${version}/g" ${CURRENT_DIR}/rpmbuild/SPECS/vesta.spec
sed -i -- "s/__VERSION__/${version}/g" ${CURRENT_DIR}/rpmbuild/SPECS/vesta-php.spec
sed -i -- "s/__VERSION__/${version}/g" ${CURRENT_DIR}/rpmbuild/SPECS/vesta-nginx.spec

sed -i -- "s/__RELEASE__/${release}/g" ${CURRENT_DIR}/rpmbuild/SPECS/vesta.spec
sed -i -- "s/__RELEASE__/${release}/g" ${CURRENT_DIR}/rpmbuild/SPECS/vesta-php.spec
sed -i -- "s/__RELEASE__/${release}/g" ${CURRENT_DIR}/rpmbuild/SPECS/vesta-nginx.spec

echo "Preparing Installation Configurations"

cd $CURRENT_DIR
cd install/rhel/7/

rm -f rhel/7/dovecot.tar.gz    > /dev/null 2>&1
rm -f rhel/7/fail2ban.tar.gz   > /dev/null 2>&1
rm -f rhel/7/firewall.tar.gz   > /dev/null 2>&1
rm -f rhel/7/packages.tar.gz   > /dev/null 2>&1
rm -f rhel/7/templates.tar.gz  > /dev/null 2>&1

tar zcvf dovecot.tar.gz dovecot      > /dev/null 2>&1
tar zcvf fail2ban.tar.gz fail2ban    > /dev/null 2>&1
tar zcvf firewall.tar.gz firewall    > /dev/null 2>&1
tar zcvf packages.tar.gz packages    > /dev/null 2>&1
tar zcvf templates.tar.gz templates  > /dev/null 2>&1

cd $CURRENT_DIR
cd install/rhel/6/

rm -f rhel/6/dovecot.tar.gz    > /dev/null 2>&1
rm -f rhel/6/fail2ban.tar.gz   > /dev/null 2>&1
rm -f rhel/6/firewall.tar.gz   > /dev/null 2>&1
rm -f rhel/6/packages.tar.gz   > /dev/null 2>&1
rm -f rhel/6/templates.tar.gz  > /dev/null 2>&1

tar zcvf dovecot.tar.gz dovecot      > /dev/null 2>&1
tar zcvf fail2ban.tar.gz fail2ban    > /dev/null 2>&1
tar zcvf firewall.tar.gz firewall    > /dev/null 2>&1
tar zcvf packages.tar.gz packages    > /dev/null 2>&1
tar zcvf templates.tar.gz templates  > /dev/null 2>&1

cd $CURRENT_DIR/rpmbuild

echo "Cleanup Old RPMBUILD Env"

rm -f ~/rpmbuild/SPECS/*
rm -f ~/rpmbuild/SOURCES/*

echo "Copy NEW Sources to RPMBUILD Env"

mv SPECS/* ~/rpmbuild/SPECS/
mv SOURCES/* ~/rpmbuild/SOURCES/

tar cvf ${CURRENT_DIR}/vesta-sources.tar ~/rpmbuild/SPECS ~/rpmbuild/SOURCES > /dev/null 2>&1 

echo "Building RPMs"

cd ~

build_signed_rpm vesta.spec x86_64
mv ~/rpmbuild/RPMS/x86_64/vesta-${version}-${release}.x86_64.rpm ${CURRENT_DIR}/
build_signed_rpm vesta-nginx.spec x86_64
mv ~/rpmbuild/RPMS/x86_64/vesta-nginx-${version}-${release}.x86_64.rpm ${CURRENT_DIR}/
build_signed_rpm vesta-php.spec x86_64
mv ~/rpmbuild/RPMS/x86_64/vesta-php-${version}-${release}.x86_64.rpm ${CURRENT_DIR}/
