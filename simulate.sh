#!/usr/bin/env bash

set -e

cp .theos/obj/iphone_simulator/debug/NotAnImpostor.dylib /opt/simject/
cp NotAnImpostor.plist /opt/simject/
resim