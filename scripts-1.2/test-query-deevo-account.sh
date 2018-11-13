#!/bin/bash
export GOPATH=/opt/gopath
export GOROOT=/opt/go
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
usage() {
	echo "Usage: $0 [-c <channel name>] [-g <orgs of peers>] [-n <chaincode name>] [-v <chaincode version>]" 1>&2
	exit 1
}
while getopts ":c:n:v:g:" o; do
	case "${o}" in
	c)
		c=${OPTARG}
		;;
	n)
		n=${OPTARG}
		;;
	v)
		v=${OPTARG}
		;;
	g)
		g=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done
shift $((OPTIND - 1))
if [ -z "${c}" ] || [ -z "${n}" ] || [ -z "${v}" ] || [ -z "${g}" ]; then
	usage
fi
echo "create channel channelID ${c} chaincodeName ${n} with ${v}"

source $(dirname "$0")/env.sh

PEER_ORGS=($g)
CHANNEL_NAME=${c}
CHANNEL_TX_FILE=$DATA/$CHANNEL_NAME.tx

QUERY_TIMEOUT=30
# test query org1
initPeerVars ${PEER_ORGS[0]} 0
echo $ORDERER_CONN_ARGS
echo "Query on $PEER_HOST ..."
# Address: "113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykiBJ7X3fFG9CMsMCXkr4JksWG2oRy7rpWLkGTM48HhHKLPyDNv8jXoh7jjSYy9zLS9sJw1X2vE2P4Pc66hJtoirwxN8j",
# Publickey: `
# -----BEGIN PUBLIC KEY-----
# MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEUkaGIAmlbgE9lfFz2wdMlZSMyTyh
# KnVw7s2wQEgkCA7yrKr8iEXxtGflsBLtqLH7LE071/G3lXn0+tjhlv1Uww==
# -----END PUBLIC KEY-----
#`,
# Balance: 1000,

$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initAcc","-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEUkaGIAmlbgE9lfFz2wdMlZSMyTyh\nKnVw7s2wQEgkCA7yrKr8iEXxtGflsBLtqLH7LE071/G3lXn0+tjhlv1Uww==\n-----END PUBLIC KEY-----","113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykiBJ7X3fFG9CMsMCXkr4JksWG2oRy7rpWLkGTM48HhHKLPyDNv8jXoh7jjSYy9zLS9sJw1X2vE2P4Pc66hJtoirwxN8j", "1000"]}' $ORDERER_CONN_ARGS
initPeerVars ${PEER_ORGS[0]} 0
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["initAcc","-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE0pMl4REOfV+19c8+QFLAco5EnM6I\n+kamXYuxYj9fulZidArnsVBD3WoHkSxESuyTpdCGB3YCNxXeaR9wI1gWgg==\n-----END PUBLIC KEY-----","113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykj3GWqqgK4rJFFrtswbE7xghrX9GRkqVPaYpf4GsSh3jGDeW8MFvubXzAzEEmLbZqvDoueLf8oPv8p5iNEFnsgSA9MeM", "2000"]}' $ORDERER_CONN_ARGS
sleep 3
# test query org0
initPeerVars ${PEER_ORGS[0]} 0
echo $ORDERER_CONN_ARGS
echo "Query on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode query -C $CHANNEL_NAME -n ${n} -c '{"Args":["getBalance","113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykiBJ7X3fFG9CMsMCXkr4JksWG2oRy7rpWLkGTM48HhHKLPyDNv8jXoh7jjSYy9zLS9sJw1X2vE2P4Pc66hJtoirwxN8j"]}' $ORDERER_CONN_ARGS
# test query org0
initPeerVars ${PEER_ORGS[1]} 0
echo $ORDERER_CONN_ARGS
echo "Query on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode query -C $CHANNEL_NAME -n ${n} -c '{"Args":["getBalance","113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykj3GWqqgK4rJFFrtswbE7xghrX9GRkqVPaYpf4GsSh3jGDeW8MFvubXzAzEEmLbZqvDoueLf8oPv8p5iNEFnsgSA9MeM"]}' $ORDERER_CONN_ARGS
sleep 3
# test query org0
initPeerVars ${PEER_ORGS[1]} 0
echo $ORDERER_CONN_ARGS
echo "Transfer on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode invoke -C $CHANNEL_NAME -n ${n} -c '{"Args":["transfer","10", "113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykj3GWqqgK4rJFFrtswbE7xghrX9GRkqVPaYpf4GsSh3jGDeW8MFvubXzAzEEmLbZqvDoueLf8oPv8p5iNEFnsgSA9MeM1002018-11-10 12:17:29.014634", "29978764154139864880696030835938256737287232151003611159021314956225371873730", "75348994682775390770944787851125569805092606536265710298111367961967701172281", "113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykiBJ7X3fFG9CMsMCXkr4JksWG2oRy7rpWLkGTM48HhHKLPyDNv8jXoh7jjSYy9zLS9sJw1X2vE2P4Pc66hJtoirwxN8j", "113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykj3GWqqgK4rJFFrtswbE7xghrX9GRkqVPaYpf4GsSh3jGDeW8MFvubXzAzEEmLbZqvDoueLf8oPv8p5iNEFnsgSA9MeM"]}' $ORDERER_CONN_ARGS
# test query org0
sleep 5
initPeerVars ${PEER_ORGS[0]} 0
echo $ORDERER_CONN_ARGS
echo "Query on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode query -C $CHANNEL_NAME -n ${n} -c '{"Args":["getBalance","113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykiBJ7X3fFG9CMsMCXkr4JksWG2oRy7rpWLkGTM48HhHKLPyDNv8jXoh7jjSYy9zLS9sJw1X2vE2P4Pc66hJtoirwxN8j"]}' $ORDERER_CONN_ARGS
# test query org0
initPeerVars ${PEER_ORGS[1]} 0
echo $ORDERER_CONN_ARGS
echo "Query on $PEER_HOST ..."
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer chaincode query -C $CHANNEL_NAME -n ${n} -c '{"Args":["getBalance","113yvjFhnmGYN2PaXfD5XT9TDHGbRUyTykj3GWqqgK4rJFFrtswbE7xghrX9GRkqVPaYpf4GsSh3jGDeW8MFvubXzAzEEmLbZqvDoueLf8oPv8p5iNEFnsgSA9MeM"]}' $ORDERER_CONN_ARGS