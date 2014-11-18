#!/bin/bash

from=$(dirname "$0")
where="${1:-/usr/local/bin}"
mkdir -p "$where" || exit

if [[ "$2" != --remove ]]; then
    cp -v "$from/easyoptions"     "$where"
    cp -v "$from/easyoptions.sh"  "$where"
    cp -v "$from/easyoptions.rb"  "$where"
else
    rm -vf "$where/easyoptions"
    rm -vf "$where/easyoptions.sh"
    rm -vf "$where/easyoptions.rb"
fi
