#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
SDIR=$(dirname "$0")
source $SDIR/env.sh

usage() {
	echo "Usage: $0 [-g <orgname>] [-r <restart>]" 1>&2
	exit 1
}
while getopts ":g:r:" o; do
	case "${o}" in
	g)
		g=${OPTARG}
		;;
	r)
		r=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done

shift $((OPTIND - 1))
if [ -z "${g}" ] || [ -z "${r}" ]; then
	usage
fi

set -e
ORG=${g}
export FABRIC_CA_SERVER_HOME=$HOME/fabric-ca
export FABRIC_CA_SERVER_TLS_ENABLED=true
export FABRIC_CA_SERVER_CSR_CN=rca.${g}.deevo.io
export FABRIC_CA_SERVER_CSR_HOSTS=rca.${g}.deevo.io
export FABRIC_CA_SERVER_DEBUG=true
BOOTSTRAP_USER=rca-${g}-admin
BOOTSTRAP_PASS=rca-${g}-adminpw
export BOOTSTRAP_USER_PASS=rca-${g}-admin:rca-${g}-adminpw
export FABRIC_CA_SERVER_CA_NAME=rca.${g}.deevo.io
export FABRIC_ORGS="replicas org0 org1 org2 org3 org4 org5"
export FABRIC_CA_SERVER_TLS_CERTFILE=$DATA/ca/tls.rca.${g}.deevo.io.pem

#rm -rf $HOME/fabric-ca/*
#rm -rf $DATA/*
#mkdir -p $DATA/ca

#mkdir -p data
#mkdir -p data/logs
export RUN_SUMPATH=./data/logs/ca-${ORG}.log

#mkdir -p ${FABRIC_CA_SERVER_HOME}
#rm -rf ${FABRIC_CA_SERVER_HOME}/*

# Initialize the root CA
if [ ${r} -eq 1 ]; then
	# cp -R ${DATA}/rca-${g}-home/* ${FABRIC_CA_SERVER_HOME}/
  echo "Restarting Fabric-CA..."
else
  rm -rf $HOME/fabric-ca/*
  rm -rf $DATA/*
  mkdir -p $DATA/ca

  mkdir -p data
  mkdir -p data/logs

  mkdir -p ${FABRIC_CA_SERVER_HOME}
  rm -rf ${FABRIC_CA_SERVER_HOME}/*

	echo "# Version of config file
version: 1.2.0

# Server listening port (default: 7054)
port: 7054

# Enables debug logging (default: false)
debug: false

# Size limit of an acceptable CRL in bytes (default: 512000)
crlsizelimit: 512000

#############################################################################
crl:
  expiry: 24h

#############################################################################
registry:
  # Maximum number of times a password/secret can be reused for enrollment
  # (default: -1, which means there is no limit)
  maxenrollments: -1

  # Contains identity information which is used when LDAP is disabled
  identities:
    - name: ${BOOTSTRAP_USER}
      pass: ${BOOTSTRAP_PASS}
      type: client
      affiliation: ""
      attrs:
        hf.Registrar.Roles: \"*\"
        hf.Registrar.DelegateRoles: \"*\"
        hf.Revoker: true
        hf.GenCRL: true
        hf.Registrar.Attributes: \"*\"
        hf.AffiliationMgr: true

#############################################################################
#  Database section
#############################################################################
db:
  type: sqlite3
  datasource: fabric-ca-server.db
  tls:
      enabled: false
      certfiles:
      client:
        certfile:
        keyfile:

#############################################################################
# Affiliations section. Fabric CA server can be bootstrapped with the
# affiliations specified in this section. Affiliations are specified as maps.
#############################################################################
affiliations:">>$FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml
	# Add the custom orgs
	for o in $FABRIC_ORGS; do
		echo "  $o: []">>$FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml
	done
echo "
#############################################################################
#  Signing section
#############################################################################
signing:
    default:
      usage:
        - digital signature
        - cert sign
        - crl sign
        - digital signature
        - key encipherment
      expiry: 8760h
    profiles:
      ca:
        usage:
          - cert sign
          - crl sign
          - digital signature
          - key encipherment
        expiry: 43800h
        caconstraint:
          isca: true
          maxpathlen: 0
      tls:
        usage:
            - signing
            - key encipherment
            - server auth
            - client auth
            - key agreement
        expiry: 8760h

###########################################################################
#  Certificate Signing Request (CSR) section.
###########################################################################
csr:
  cn: fabric-ca-server
  names:
    - C: US
      ST: California
      L:
      O: ${g}
      OU: COP
  hosts:
    - ubuntu
    - localhost
  ca:
    expiry: 131400h
    pathlength: 1

#############################################################################
# BCCSP (BlockChain Crypto Service Provider) section is used to select which
# crypto library implementation to use
#############################################################################
bccsp:
    default: SW
    sw:
        hash: SHA2
        security: 256
        filekeystore:
            # The directory used for the software file-based keystore
            keystore: msp/keystore

cacount:

cafiles:

intermediate:
  parentserver:
    url:
    caname:

  enrollment:
    hosts:
    profile:
    label:

  tls:
    certfiles:
    client:
      certfile:
      keyfile:
" >> $FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml
	fabric-ca-server init -b $BOOTSTRAP_USER_PASS
fi

# Start the root CA

logr "Start CA server"

fabric-ca-server start --ca.certfile $FABRIC_CA_SERVER_HOME/ca-cert.pem -b $BOOTSTRAP_USER_PASS >$RUN_SUMPATH 2>&1 &
cp $FABRIC_CA_SERVER_HOME/ca-cert.pem $DATA/ca/rca.${g}.deevo.io.pem
echo "Success see in $RUN_SUMPATH"
