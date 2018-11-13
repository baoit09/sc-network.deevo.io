#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
usage() {
	echo "Usage: $0 [-g <orgname>] [-n <numberpeer>] [-s <run_system_account_or_not>]" 1>&2
	exit 1
}
while getopts ":g:n:s:" o; do
	case "${o}" in
	g)
		g=${OPTARG}
		;;
	n)
		n=${OPTARG}
		;;
	s)
		s=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done
shift $((OPTIND - 1))
if [ -z "${g}" ] || [ -z "${n}" ] || [ -z "${s}" ]; then
	usage
fi
ORG=${g}
NUMBER=${n}
SYSACCOUNT=${s}

source $(dirname "$0")/env.sh
initPeerVars ${ORG} ${NUMBER}

# cp ../config-1.2/configtx.yaml ${FABRIC_CFG_PATH}/configtx.yaml
if [ ${SYSACCOUNT} -eq 1 ] ; then
	cp ../config-1.2/core-account.yaml ${FABRIC_CFG_PATH}/core.yaml
else
	cp ../config-1.2/core.yaml ${FABRIC_CFG_PATH}/core.yaml
fi

mkdir -p data
mkdir -p data/logs

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer node start >data/logs/${PEER_NAME}.out 2>&1 &
echo "Success see in data/logs/${PEER_NAME}.out"
