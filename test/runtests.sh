#-------------------------------------------------------------------------------------------------------
# Copyright (C) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
#-------------------------------------------------------------------------------------------------------
#

# CI ONLY
# This script is mainly for CI only. In case you have ChakraCore is compiled for multiple
# targets, this script may fail to test all of them. Use runtests.py instead.

test_path=`dirname "$0"`

build_type=
binary_path=
release_build=0
test_variant=$1

if [[ -f "$test_path/../out/Debug/ch" ]]; then
    echo "Warning: Debug build was found"
    binary_path="Debug";
    build_type="-d"
elif [[ -f "$test_path/../out/Test/ch" ]]; then
    echo "Warning: Test build was found"
    binary_path="Test";
    build_type="-t"
elif [[ -f "$test_path/../out/Release/ch" ]]; then
    binary_path="Release";
    echo "Warning: Release build was found"
    release_build=1
else
    echo 'Error: ch not found- exiting'
    exit 1
fi

if [[ $release_build != 1 ]]; then
    "$test_path/runtests.py" $build_type --not-tag exclude_jenkins $test_variant
    if [[ $? != 0 ]]; then
        exit 1
    fi
else
    # TEST flags are not enabled for release build
    # however we would like to test if the compiled binary
    # works or not
    RES=$($test_path/../out/${binary_path}/ch $test_path/basics/hello.js)
    if [[ $RES =~ "Error :" ]]; then
        echo "FAILED"
        exit 1
    else
        echo "Release Build Passes hello.js run"
    fi
fi

RES=$(pwd)
CH_ABSOLUTE_PATH="$RES/${test_path}/../out/${binary_path}/ch"
RES=$(cd $RES/$test_path/native-tests; ./test_native.sh ${CH_ABSOLUTE_PATH} ${binary_path} 2>&1)
if [[ $? != 0 ]]; then
    echo "Error: Native tests failed"
    echo -e "$RES"
    exit 1
fi
