#!/bin/bash

VERSION=$1

# ===========================
# Functions

run_git_clean()
{
    DIRECTORY_TO_CLEAN=$1
    rm -rf ${DIRECTORY_TO_CLEAN}/.git ${DIRECTORY_TO_CLEAN}/.gitignore
}

download_autozoil_from_git()
{
    mkdir -p src
    cd src
    rm -rf autozoil
    git clone https://github.com/filipg/autozoil
    cd ..
}

preprocess_autozoil_pm_pre()
{
    mv $MODULE_DIRECTORY_NAME/lib/Autozoil.pm.pre $MODULE_DIRECTORY_NAME/lib/Autozoil.pm
    PREPROCESS_FILENAME=$MODULE_DIRECTORY_NAME/lib/Autozoil.pm

    cat $PREPROCESS_FILENAME | sed -r "s/@@@@@@VERSION_NUMBER@@@@@@/$VERSION/"|sponge $PREPROCESS_FILENAME
}

copy_template()
{
    echo "Copying template"

    cp -rf $TEMPLATE_DIRECTORY_NAME $MODULE_DIRECTORY_NAME
    run_git_clean $MODULE_DIRECTORY_NAME

    # @todo preprocess Autozoil/lib/Autozoil.pm.pre
    preprocess_autozoil_pm_pre

    if [[ ! -d $MODULE_DIRECTORY_NAME/t ]]; then
        mkdir $MODULE_DIRECTORY_NAME/t
    fi
}

# ===========================
# MAIN


MODULE_NAME='Autozoil'
INPUT_MODULE_DIRECTORY_NAME=`echo "$MODULE_NAME" | sed -r 's/::/\//g'`
echo "INPUT_MODULE_DIRECTORY_NAME $INPUT_MODULE_DIRECTORY_NAME"
INPUT_MODULE_PATH=$INPUT_MODULE_DIRECTORY_NAME.pm

MODULE_DIRECTORY_NAME=`echo "$MODULE_NAME" | sed -r 's/::/-/g'`
TEMPLATE_DIRECTORY_NAME=$MODULE_DIRECTORY_NAME

if [[ ! -e $TEMPLATE_DIRECTORY_NAME ]]; then
    echo "ERROR: No template found for $TEMPLATE_DIRECTORY_NAME"
    exit 1;
fi


MODULE_DIRECTORY_NAME=$MODULE_DIRECTORY_NAME-$VERSION
MODULE_LIB_DIRECTORY=$MODULE_DIRECTORY_NAME/lib
MODULE_SCRIPTS_DIRECTORY=$MODULE_DIRECTORY_NAME/scripts
MODULE_TESTS_DIRECTORY=$MODULE_DIRECTORY_NAME/t

echo "Module directory name: $MODULE_DIRECTORY_NAME"

if [[ -e $MODULE_DIRECTORY_NAME ]]; then
    echo "Removing previous version: $MODULE_DIRECTORY_NAME";
    rm -rf $MODULE_DIRECTORY_NAME
fi

SOURCE_CODE_PATH=./src/autozoil

download_autozoil_from_git

MAIN_PATH=$SOURCE_CODE_PATH/Autozoil
TESTS_PATH=$SOURCE_CODE_PATH/t/

copy_template

TARGET_SOURCE_CODE_PATH=$MODULE_LIB_DIRECTORY/$INPUT_MODULE_DIRECTORY_NAME
mkdir -p $TARGET_SOURCE_CODE_PATH

echo "Target: $TARGET_SOURCE_CODE_PATH"
cp -rf $MAIN_PATH/* $TARGET_SOURCE_CODE_PATH

cp -f $SOURCE_CODE_PATH/autozoil.pl $MODULE_DIRECTORY_NAME

# copy test data
cp -rf $SOURCE_CODE_PATH/t/Autozoil $MODULE_DIRECTORY_NAME
rm -f `find $MODULE_DIRECTORY_NAME/Autozoil -type f -regextype posix-extended ! -regex '.*\.(tex|pdf)'`


run_git_clean $MODULE_LIB_DIRECTORY

echo "Copying tests"
for test_path in `find $TESTS_PATH -regex '.*\.t$'`
do
    test_filename=`echo "$test_path" | sed -r 's/^.*\///;'`
    initial_out_path=$MODULE_TESTS_DIRECTORY/$test_filename
    out_path=$initial_out_path
    index=0
    while [[ -e $out_path ]]; do
        index=$[index + 1]
        out_path=`echo "$initial_out_path" | sed -r "s/\.t/-$index.t/"`
    done

    cp $test_path $out_path
done

run_git_clean $MODULE_TESTS_DIRECTORY


rm -f `find $MODULE_DIRECTORY_NAME -regex '.*~'`
tar -czf $MODULE_DIRECTORY_NAME.tgz $MODULE_DIRECTORY_NAME
