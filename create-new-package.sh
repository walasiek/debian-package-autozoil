#!/bin/bash

echo "Start: " `date`
VERSION=$1

MAINTAINER_MAIL=mwalas@amu.edu.pl

if [[ -z $VERSION ]]; then
    echo 'First parameter should be version in format x.y (e.g. 0.001)'
    exit 1;
fi

PACKAGE=autozoil
PERLMODULENAME=Autozoil
PERLMODULEDIRECTORYNAME=$PERLMODULENAME-$VERSION

WORKING_DIR=`pwd`/work
CPAN_MODULES_DIR=`pwd`/cpan-module
DEBIAN_FILES_DIR=`pwd`/debian-files
BASE_DEBIAN_FILES_DIR=${DEBIAN_FILES_DIR}/base
PATCH_DEBIAN_FILES_DIR=${DEBIAN_FILES_DIR}/patches

cd cpan-module
echo "Creating perl module..."
./create-new-dist.sh $VERSION
cd ..

if [[ ! -d $WORKING_DIR ]]; then
    echo "Create working dir: $WORKING_DIR"
    mkdir -p $WORKING_DIR
else
    echo "Removing files from working dir: $WORKING_DIR"
    rm -rf $WORKING_DIR/*
fi

cd $WORKING_DIR

ORIG_SOURCE=${PACKAGE}-${VERSION}
ORIG_TARBALL=${PACKAGE}-${VERSION}.tar.gz

# creation of the package
if [[ -d $PERLMODULEDIRECTORYNAME ]]; then
    echo "Removing old work/$PERLMODULEDIRECTORYNAME"
    rm -rf $PERLMODULEDIRECTORYNAME
fi

cp -rf $CPAN_MODULES_DIR/$PERLMODULEDIRECTORYNAME .

cd $PERLMODULEDIRECTORYNAME

# DEBIAN FILES CREATION
TEMP_DEBIAN_FILES_DIR=${DEBIAN_FILES_DIR}/temp

if [[ -d $TEMP_DEBIAN_FILES_DIR ]]; then
    rm -rf $TEMP_DEBIAN_FILES_DIR
fi
mkdir $TEMP_DEBIAN_FILES_DIR

cp -r $BASE_DEBIAN_FILES_DIR/* $TEMP_DEBIAN_FILES_DIR

# Patch for different versions of Ubuntu
UBUNTU_VERSION_BELOW_11=`cat /etc/issue.net |sed -r 's/\..*//' | egrep '^Ubuntu (10|[0123456789])$'`

if [[ $UBUNTU_VERSION_BELOW_11 ]]; then
    # patch for version
    CURRENT_PATCH_DEBIAN_FILES_DIR=${PATCH_DEBIAN_FILES_DIR}/ubuntu-10
fi

if [[ $CURRENT_PATCH_DEBIAN_FILES_DIR ]]; then

    for patch_file in $CURRENT_PATCH_DEBIAN_FILES_DIR/*.patch
    do
        INPUT_FILE=`echo "$patch_file"|sed -r 's/.patch$//;s/^.*\///g;'`
        echo "Patching file: $INPUT_FILE"
        INPUT_PATH=$TEMP_DEBIAN_FILES_DIR/$INPUT_FILE
        patch $INPUT_PATH $patch_file
    done
fi

mkdir debian

cp -r ${TEMP_DEBIAN_FILES_DIR}/* ./debian
rm debian/*~
rm -rf $TEMP_DEBIAN_FILES_DIR



# produce deb
debuild

#mv ../*.deb ../../packages/

echo "End: " `date`
