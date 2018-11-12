#!/bin/bash
set -e
usage() {
	echo "Usage: $0 [-o <orgs of orderers>] -g [orgs of peers] -r [orgs of replicas]" 1>&2
	exit 1
}

while getopts ":o:g:r:" x; do
	case "${x}" in
	o)
		o=${OPTARG}
		;;
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
if [ -z "${o}" ] || [ -z "${g}" ] || [ -z "${r}" ]; then
	usage
fi

CONFIGTX_FILE=../config-1.2/configtx.yaml

if [ -f $CONFIGTX_FILE ]; then
	rm $CONFIGTX_FILE
fi

echo "# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

---
################################################################################
#
#   ORGANIZATIONS
#
#   This section defines the organizational identities that can be referenced
#   in the configuration profiles.
#
################################################################################
Organizations:" >> $CONFIGTX_FILE

for org in $o; do
    echo "
    - &${org}
        # Name is the key by which this org will be referenced in channel
        # configuration transactions.
        # Name can include alphanumeric characters as well as dots and dashes.
        Name: ${org}

        # ID is the key by which this org's MSP definition will be referenced.
        # ID can include alphanumeric characters as well as dots and dashes.
        ID: ${org}MSP

        # MSPDir is the filesystem path which contains the MSP configuration.
        MSPDir: /home/baotq/hyperledgerconfig/data/orgs/${org}/msp

        # Policies defines the set of policies at this level of the config tree
        # For organization policies, their canonical path is usually
        #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
        Policies: &${org}Policies
            Readers:
                Type: Signature
                Rule: \"OR('${org}MSP.member')\"
                # If your MSP is configured with the new NodeOUs, you might
                # want to use a more specific rule like the following:
                # Rule: \"OR('SampleOrg.admin', 'SampleOrg.peer', 'SampleOrg.client')\"
            Writers:
                Type: Signature
                Rule: \"OR('${org}MSP.member')\"
                # If your MSP is configured with the new NodeOUs, you might
                # want to use a more specific rule like the following:
                # Rule: \"OR('SampleOrg.admin', 'SampleOrg.client')\"
            Admins:
                Type: Signature
                Rule: \"OR('${org}MSP.admin')\"" >> $CONFIGTX_FILE
done

for org in $r; do
    echo "
    - &${org}
        Name: ${org}
        ID: ${org}MSP
        MSPDir: /home/baotq/hyperledgerconfig/data/orgs/${org}/msp
        Policies:
            Readers:
                Type: Signature
                Rule: \"OR('${org}MSP.member')\"
            Writers:
                Type: Signature
                Rule: \"AND('${org}MSP.member','${org}MSP.member')\"
            Admins:
                Type: Signature
                Rule: \"OR('${org}MSP.admin')\"" >> $CONFIGTX_FILE
done

for org in $g; do
    echo "
    - &${org}
        Name: ${org}
        ID: ${org}MSP
        MSPDir: /home/baotq/hyperledgerconfig/data/orgs/${org}/msp
        Policies: &${org}Policies
            Readers:
                Type: Signature
                Rule: \"OR('${org}MSP.member')\"
            Writers:
                Type: Signature
                Rule: \"OR('${org}MSP.member')\"
            Admins:
                Type: Signature
                Rule: \"OR('${org}MSP.admin')\"
        AnchorPeers:
            - Host: peer0.${org}.deevo.io
              Port: 7051" >> $CONFIGTX_FILE
done

echo "
################################################################################
#
#   CAPABILITIES
#
#   This section defines the capabilities of fabric network. This is a new
#   concept as of v1.1.0 and should not be utilized in mixed networks with
#   v1.0.x peers and orderers.  Capabilities define features which must be
#   present in a fabric binary for that binary to safely participate in the
#   fabric network.  For instance, if a new MSP type is added, newer binaries
#   might recognize and validate the signatures from this type, while older
#   binaries without this support would be unable to validate those
#   transactions.  This could lead to different versions of the fabric binaries
#   having different world states.  Instead, defining a capability for a channel
#   informs those binaries without this capability that they must cease
#   processing transactions until they have been upgraded.  For v1.0.x if any
#   capabilities are defined (including a map with all capabilities turned off)
#   then the v1.0.x peer will deliberately crash.
#
################################################################################
Capabilities:
    # Channel capabilities apply to both the orderers and the peers and must be
    # supported by both.  Set the value of the capability to true to require it.
    Channel: &ChannelCapabilities
        # V1.1 for Channel is a catchall flag for behavior which has been
        # determined to be desired for all orderers and peers running v1.0.x,
        # but the modification of which would cause incompatibilities.  Users
        # should leave this flag set to true.
        V1_1: true

    # Orderer capabilities apply only to the orderers, and may be safely
    # manipulated without concern for upgrading peers.  Set the value of the
    # capability to true to require it.
    Orderer: &OrdererCapabilities
        # V1.1 for Order is a catchall flag for behavior which has been
        # determined to be desired for all orderers running v1.0.x, but the
        # modification of which  would cause incompatibilities.  Users should
        # leave this flag set to true.
        V1_1: true

    # Application capabilities apply only to the peer network, and may be
    # safely manipulated without concern for upgrading orderers.  Set the value
    # of the capability to true to require it.
    Application: &ApplicationCapabilities
        # V1.2 for Application enables the new non-backwards compatible
        # features and fixes of fabric v1.2, it implies V1_1.
        V1_2: true
        # V1.1 for Application enables the new non-backwards compatible
        # features and fixes of fabric v1.1 (note, this need not be set if
        # V1_2 is set).
        V1_1: false

################################################################################
#
#   ORDERER
#
#   This section defines the values to encode into a config transaction or
#   genesis block for orderer related parameters.
#
################################################################################
Orderer: &OrdererDefaults

    # Orderer Type: The orderer implementation to start.
    # Available types are \"solo\" and \"kafka\".
    OrdererType: bftsmart

    # Addresses here is a nonexhaustive list of orderers the peers and clients can
    # connect to. Adding/removing nodes from this list has no impact on their
    # participation in ordering.
    # NOTE: In the solo case, this should be a one-item list.
    Addresses:" >> $CONFIGTX_FILE

for org in $o; do
echo "        - orderer0.${org}.deevo.io:7050" >> $CONFIGTX_FILE
done

echo "
    # Batch Timeout: The amount of time to wait before creating a batch.
    BatchTimeout: 2s

    # Batch Size: Controls the number of messages batched into a block.
    BatchSize:

        # Max Message Count: The maximum number of messages to permit in a
        # batch.
        MaxMessageCount: 10

        AbsoluteMaxBytes: 99 MB

        # Preferred Max Bytes: The preferred maximum number of bytes allowed
        # for the serialized messages in a batch. A message larger than the
        # preferred max bytes will result in a batch larger than preferred max
        # bytes.
        PreferredMaxBytes: 512 KB

    # Max Channels is the maximum number of channels to allow on the ordering
    # network. When set to 0, this implies no maximum number of channels.
    MaxChannels: 0

    Kafka:
        # Brokers: A list of Kafka brokers to which the orderer connects. Edit
        # this list to identify the brokers of the ordering service.
        # NOTE: Use IP:port notation.
        Brokers:
            - kafka0:9092
            - kafka1:9092
            - kafka2:9092

    #JCS: BFT-SMaRt options
    BFTsmart:

        # ConnectionPoolSize: The size of the connection pool that links the golang component to the java component.
        ConnectionPoolSize: 20

        # RecvPort: The localhost TCP port from which the java component sends blocks to the golang component.
        RecvPort: 9999

    # Organizations lists the orgs participating on the orderer side of the
    # network.
    Organizations:

    # Policies defines the set of policies at this level of the config tree
    # For Orderer policies, their canonical path is
    #   /Channel/Orderer/<PolicyName>
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: \"ANY Readers\"
        Writers:
            Type: ImplicitMeta
            Rule: \"ANY Writers\"
        Admins:
            Type: ImplicitMeta
            Rule: \"MAJORITY Admins\"
        # BlockValidation specifies what signatures must be included in the block
        # from the orderer for the peer to validate it.
        BlockValidation:
            Type: ImplicitMeta
            Rule: \"ANY Writers\"

    # Capabilities describes the orderer level capabilities, see the
    # dedicated Capabilities section elsewhere in this file for a full
    # description
    Capabilities:
        <<: *OrdererCapabilities

################################################################################
#
#   APPLICATION
#
#   This section defines the values to encode into a config transaction or
#   genesis block for application-related parameters.
#
################################################################################
Application: &ApplicationDefaults
    ACLs: &ACLsDefault
        # This section provides defaults for policies for various resources
        # in the system. These \"resources\" could be functions on system chaincodes
        # (e.g., \"GetBlockByNumber\" on the \"qscc\" system chaincode) or other resources
        # (e.g.,who can receive Block events). This section does NOT specify the resource's
        # definition or API, but just the ACL policy for it.
        #
        # User's can override these defaults with their own policy mapping by defining the
        # mapping under ACLs in their channel definition

        #---Lifecycle System Chaincode (lscc) function to policy mapping for access control---#

        # ACL policy for lscc's \"getid\" function
        lscc/ChaincodeExists: /Channel/Application/Readers

        # ACL policy for lscc's \"getdepspec\" function
        lscc/GetDeploymentSpec: /Channel/Application/Readers

        # ACL policy for lscc's \"getccdata\" function
        lscc/GetChaincodeData: /Channel/Application/Readers

        # ACL Policy for lscc's \"getchaincodes\" function
        lscc/GetInstantiatedChaincodes: /Channel/Application/Readers

        #---Query System Chaincode (qscc) function to policy mapping for access control---#

        # ACL policy for qscc's \"GetChainInfo\" function
        qscc/GetChainInfo: /Channel/Application/Readers

        # ACL policy for qscc's \"GetBlockByNumber\" function
        qscc/GetBlockByNumber: /Channel/Application/Readers

        # ACL policy for qscc's  \"GetBlockByHash\" function
        qscc/GetBlockByHash: /Channel/Application/Readers

        # ACL policy for qscc's \"GetTransactionByID\" function
        qscc/GetTransactionByID: /Channel/Application/Readers

        # ACL policy for qscc's \"GetBlockByTxID\" function
        qscc/GetBlockByTxID: /Channel/Application/Readers

        #---Configuration System Chaincode (cscc) function to policy mapping for access control---#

        # ACL policy for cscc's \"GetConfigBlock\" function
        cscc/GetConfigBlock: /Channel/Application/Readers

        # ACL policy for cscc's \"GetConfigTree\" function
        cscc/GetConfigTree: /Channel/Application/Readers

        # ACL policy for cscc's \"SimulateConfigTreeUpdate\" function
        cscc/SimulateConfigTreeUpdate: /Channel/Application/Readers

        #---Miscellanesous peer function to policy mapping for access control---#

        # ACL policy for invoking chaincodes on peer
        peer/Propose: /Channel/Application/Writers

        # ACL policy for chaincode to chaincode invocation
        peer/ChaincodeToChaincode: /Channel/Application/Readers

        #---Events resource to policy mapping for access control###---#

        # ACL policy for sending block events
        event/Block: /Channel/Application/Readers

        # ACL policy for sending filtered block events
        event/FilteredBlock: /Channel/Application/Readers

    # Organizations lists the orgs participating on the application side of the
    # network.
    Organizations:

    # Policies defines the set of policies at this level of the config tree
    # For Application policies, their canonical path is
    #   /Channel/Application/<PolicyName>
    Policies: &ApplicationDefaultPolicies
        Readers:
            Type: ImplicitMeta
            Rule: \"ANY Readers\"
        Writers:
            Type: ImplicitMeta
            Rule: \"ANY Writers\"
        Admins:
            Type: ImplicitMeta
            Rule: \"MAJORITY Admins\"

    # Capabilities describes the application level capabilities, see the
    # dedicated Capabilities section elsewhere in this file for a full
    # description
    Capabilities:
        <<: *ApplicationCapabilities


################################################################################
#
#   CHANNEL
#
#   This section defines the values to encode into a config transaction or
#   genesis block for channel related parameters.
#
################################################################################
Channel: &ChannelDefaults
    # Policies defines the set of policies at this level of the config tree
    # For Channel policies, their canonical path is
    #   /Channel/<PolicyName>
    Policies:
        # Who may invoke the 'Deliver' API
        Readers:
            Type: ImplicitMeta
            Rule: \"ANY Readers\"
        # Who may invoke the 'Broadcast' API
        Writers:
            Type: ImplicitMeta
            Rule: \"ANY Writers\"
        # By default, who may modify elements at this config level
        Admins:
            Type: ImplicitMeta
            Rule: \"MAJORITY Admins\"


    # Capabilities describes the channel level capabilities, see the
    # dedicated Capabilities section elsewhere in this file for a full
    # description
    Capabilities:
        <<: *ChannelCapabilities

################################################################################
#
#   PROFILES
#
#   Different configuration profiles may be encoded here to be specified as
#   parameters to the configtxgen tool. The profiles which specify consortiums
#   are to be used for generating the orderer genesis block. With the correct
#   consortium members defined in the orderer genesis block, channel creation
#   requests may be generated with only the org member names and a consortium
#   name.
#
################################################################################
Profiles:

    # JCS: my profile
    # SampleSingleMSPBFTsmart defines a configuration which uses the bftsmart orderer,
    # and contains a single MSP definition (the MSP sampleconfig).
    # The Consortium SampleConsortium has only a single member, SampleOrg
    SampleSingleMSPBFTsmart:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            OrdererType: bftsmart
            Organizations:" >> $CONFIGTX_FILE

for org in $o; do
    echo "                - *${org}" >> $CONFIGTX_FILE
done
for org in $r; do
    echo "                - *${org}" >> $CONFIGTX_FILE
done
echo "        Application:
            <<: *ApplicationDefaults
            Organizations:" >> $CONFIGTX_FILE
for org in $g; do
    echo "                - *${org}" >> $CONFIGTX_FILE
done
echo "        Consortiums:
            SampleConsortium:
                Organizations:" >> $CONFIGTX_FILE
for org in $g; do
    echo "                    - *${org}" >> $CONFIGTX_FILE
done
echo "
    # SampleSingleMSPChannel defines a channel with only the sample org as a
    # member. It is designed to be used in conjunction with SampleSingleMSPSolo
    # and SampleSingleMSPKafka orderer profiles.
    SampleSingleMSPChannel:
        Consortium: SampleConsortium
        Application:
            <<: *ApplicationDefaults
            Organizations:" >> $CONFIGTX_FILE
for org in $g; do
    echo "                - *${org}" >> $CONFIGTX_FILE
done
