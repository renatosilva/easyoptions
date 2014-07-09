#!/bin/bash

from=$(dirname "$0")

if [[ "$1" != --remove ]]; then
    cp -v "$from/easyoptions.sh" /usr/local/bin/easyoptions
    cp -v "$from/easyoptions.rb" /usr/local/bin
else
    rm -vf /usr/local/bin/easyoptions
    rm -vf /usr/local/bin/easyoptions.rb
fi
