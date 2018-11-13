#!/bin/bash
cd $GOPATH/src/github.com/deevotech
rm -rf sc-chaincode.deevo.io
git clone git@github.com:deevotech/sc-chaincode.deevo.io.git -b datlv
cd $GOPATH/src/github.com/deevotech/sc-chaincode.deevo.io/deevo-account
go build -buildmode=plugin
sudo mkdir -p /opt/lib
sudo chmod 777 -R /opt/lib
cp deevo-account.so /opt/lib/