#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
usage() { echo "Usage: $0 [-g <orgname>] [-n <number>]" 1>&2; exit 1; }
while getopts ":g:n:" o; do
    case "${o}" in
        g)
            g=${OPTARG}
            ;;
        n)
            n=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -z "${g}" ] || [ -z "${n}" ] ; then
    usage
fi

ORG=${g}
NUMBER=${n}

source $(dirname "$0")/env.sh
initOrdererVars ${ORG} ${n}

rm -rf $ORDERER_FILELEDGER_LOCATION
mkdir -p data
mkdir -p data/logs
if [ -f ./data/logs/orderer.out ] ; then
rm ./data/logs/orderer.out
fi
echo $ORDERER_GENERAL_LOCALMSPDIR
cp ../config-1.2/configtx.yaml ${FABRIC_CFG_PATH}/configtx.yaml
cp ../config-1.2/core.yaml ${FABRIC_CFG_PATH}/core.yaml
cp ../config-1.2/orderer.yaml ${FABRIC_CFG_PATH}/orderer.yaml

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/orderer start > ./data/logs/orderer.out 2>&1 &
echo "done see data/logs/orderer.out"

