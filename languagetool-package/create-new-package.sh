#!/bin/bash

echo "RUN WITH SUDO!"

VERSION=1.7
PACKAGENAME=LanguageTool-$VERSION
WORKING_DIR=`pwd`/work

# ===================================

download_jar()
{
#    wget -O languagetool.zip http://www.languagetool.org/download/LanguageTool-$VERSION.oxt
    cp ~/Pulpit/languagetool.zip .
}


# ===================================


if [[ ! -d $WORKING_DIR ]]; then
    mkdir -p $WORKING_DIR
fi


echo "Download language tool"

download_jar

if [[ -d $WORKING_DIR/$PACKAGENAME ]]; then
    echo "Removing $WORKING_DIR/$PACKAGENAME"
    rm -rf $WORKING_DIR/$PACKAGENAME
fi

mkdir -p $WORKING_DIR/$PACKAGENAME

mkdir $WORKING_DIR/$PACKAGENAME/debian/

cp -rf debian-files/*  $WORKING_DIR/$PACKAGENAME/debian/
cp languagetool.zip $WORKING_DIR/$PACKAGENAME/debian/input/

mv $WORKING_DIR/$PACKAGENAME/debian/rules $WORKING_DIR/$PACKAGENAME/

cd $WORKING_DIR/$PACKAGENAME/

./rules

cd ../../

if [[ ! -d packages ]]; then
    mkdir packages
fi

mv work/*.deb packages/

rm -rf $TEMPDIR