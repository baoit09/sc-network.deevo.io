#!/bin/bash
sudo apt-get update
sudo apt-get install -y unzip autoconf build-essential libc6-dev-i386
sudo apt-get clean

sudo apt-get update
sudo apt-get install -y apt-utils python-dev
sudo apt-get install -y libsnappy-dev zlib1g-dev libbz2-dev libyaml-dev libltdl-dev libtool libc6
sudo apt-get install -y python-pip
sudo apt-get install -y tree jq unzip
sudo rm -rf /var/cache/apt

mkdir -p $GOPATH/src/github.com/hyperledger
rm -rf $GOPATH/src/github.com/hyperledger/fabric
cd $GOPATH/src/github.com/hyperledger

go get github.com/golang/protobuf/protoc-gen-go
go get github.com/kardianos/govendor
go get golang.org/x/lint/golint
go get golang.org/x/tools/cmd/goimports
go get github.com/onsi/ginkgo/ginkgo
go get github.com/axw/gocov/...
go get github.com/client9/misspell/cmd/misspell
go get github.com/AlekSi/gocov-xml

# Clone the Hyperledger Fabric code and cp sample config files
FABRIC_ROOT=$GOPATH/src/github.com/hyperledger/fabric

cd $GOPATH/src/github.com/hyperledger
git clone https://github.com/baoit09/fabric -b release-1.2-deevo

#cp $FABRIC_ROOT/devenv/limits.conf /etc/security/limits.conf
cd $GOPATH/src/github.com/hyperledger/fabric
GO_TAGS=pluginsenabled make dist-clean peer

sudo mkdir -p /var/hyperledger
sudo chmod 777 -R /var/hyperledger
