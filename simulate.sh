#!/usr/bin/env bash

if [ -z "${IOS_CERTIFICATE}" ]; then
  echo "Environment variable IOS_CERTIFICATE is not set!"
  exit 1
fi

set -e

if [ "$1" == "ios" ]; then
  export NAI_TARGET="iOS_Simulator"
  resim="resim_ios"
  SIMJECT_DIR="/opt/simject"
elif [ "$1" == "tvos" ]; then
  export NAI_TARGET="tvOS_Simulator"
  resim="resim_tvos"
  SIMJECT_DIR="/opt/simjectTV"
else
  echo "No target supplied!"
  exit 1
fi

FINALPACKAGE=1 DEBUG=0 make clean all
rm -f ${SIMJECT_DIR}/NotAnImpostor.*
rm -rf ${SIMJECT_DIR}/NotAnImpostor
cp -r "layout/Library/Application Support/NotAnImpostor" ${SIMJECT_DIR}/NotAnImpostor
cp .theos/obj/iphone_simulator/NotAnImpostor.dylib ${SIMJECT_DIR}/
cp NotAnImpostor.plist ${SIMJECT_DIR}/
"${resim}" all
