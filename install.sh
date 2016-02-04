#!/bin/bash
BASEDIR=$(dirname $0)
echo "Script location: ${BASEDIR}"
cd ${BASEDIR}
bundle install --path vendor/bundle