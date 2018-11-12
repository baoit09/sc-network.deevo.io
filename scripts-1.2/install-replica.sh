#!/bin/bash

sudo apt-get clean
sudo rm -rf /var/cache/oracle-jdk8-installer

sudo apt-get update -y
sudo apt-get install -y default-jre
sudo apt-get install -y default-jdk
sudo rm -rf /var/cache/oracle-jdk8-installer

sudo update-alternatives --config javac

sudo apt-get update
sudo apt-get install -y ant unzip wget autoconf build-essential libc6-dev-i386
sudo apt-get clean

rm -rf ~/juds
mkdir ~/juds
cd ~/juds

git clone https://github.com/mcfunley/juds

echo $(ls $JAVA_HOME/bin)

cd juds

./autoconf.sh
./configure
make
sudo make install

mkdir -p $GOPATH/src/github.com/hyperledger
rm -rf $GOPATH/src/github.com/hyperledger/fabric-orderingservice

cd $GOPATH/src/github.com/hyperledger
git clone https://github.com/baoit09/fabric-orderingservice -b release-1.2-deevo
cd $GOPATH/src/github.com/hyperledger/fabric-orderingservice
ant clean
ant
