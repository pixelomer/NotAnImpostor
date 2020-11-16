#!/usr/bin/env bash

if [ -z "${IOS_CERTIFICATE}" ]; then
  echo "Environment variable IOS_CERTIFICATE is not set!"
  exit 1
fi

set -e

FINALPACKAGE=1 DEBUG=0 NAI_SIMULATOR=1 make clean all
rm -f /opt/simject/NotAnImpostor.*
rm -rf /opt/simject/NotAnImpostor
cp -r "layout/Library/Application Support/NotAnImpostor" /opt/simject/NotAnImpostor
cp .theos/obj/iphone_simulator/NotAnImpostor.dylib /opt/simject/
cp NotAnImpostor.plist /opt/simject/
resim all