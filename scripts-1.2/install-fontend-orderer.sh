#!/bin/bash
# sudo usermod -a -G docker $USER
# then logout and reboot
# in /etc/environment
# GOROOT="/opt/go"
# GOPATH="/opt/gopath"
# source /etc/environment
# and in ~/.profile
# export GOROOT="/opt/go"
# export GOPATH="/opt/gopath"
# PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
# export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
sudo apt-get clean && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /var/cache/oracle-jdk8-installer;

sudo apt-get update -y && \
apt-get install -y default-jre && \
apt-get install -y default-jdk && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /var/cache/oracle-jdk8-installer;

sudo update-alternatives --config javac

sudo apt-get update && \
apt-get install -y ant && \
apt-get install -y unzip && \
apt-get install -y wget && \
apt-get install -y autoconf && \
apt-get install -y build-essential && \
apt-get install -y libc6-dev-i386 && \
apt-get clean;

sudo apt-get update \
        && apt-get install -y apt-utils python-dev \
        && apt-get install -y libsnappy-dev zlib1g-dev libbz2-dev libyaml-dev libltdl-dev libtool libc6 \
        && apt-get install -y python-pip \
        && apt-get install -y tree jq unzip\
        && rm -rf /var/cache/apt;

mkdir -p $GOPATH/src/github.com/hyperledger
cd $GOPATH/src/github.com/hyperledger

wget https://github.com/mcfunley/juds/archive/master.zip --output-document=/tmp/juds.zip;

echo $(ls $JAVA_HOME/bin)

unzip /tmp/juds.zip -d /tmp/juds;
cd /tmp/juds/juds-master;
cd /tmp/juds/juds-master && \
./autoconf.sh && \
./configure && \
make && \
make install;
rm -rf /tmp/juds.zip
rm -rf /tmp/juds

wget https://github.com/deevotech/fabric-orderingservice/archive/release-1.2-deevo.zip --output-document=/tmp/fabric-orderingservice.zip
unzip /tmp/fabric-orderingservice.zip -d $GOPATH/src/github.com/hyperledger/
mv $GOPATH/src/github.com/hyperledger/fabric-orderingservice-release-1.2-deevo $GOPATH/src/github.com/hyperledger/fabric-orderingservice

cd $GOPATH/src/github.com/hyperledger/fabric-orderingservice && \
ant clean && \
ant;
rm -rf /tmp/fabric-orderingservice.zip;

go get github.com/golang/protobuf/protoc-gen-go \
        && go get github.com/kardianos/govendor \
        && go get golang.org/x/lint/golint \
        && go get golang.org/x/tools/cmd/goimports \
        && go get github.com/onsi/ginkgo/ginkgo \
        && go get github.com/axw/gocov/... \
        && go get github.com/client9/misspell/cmd/misspell \
        && go get github.com/AlekSi/gocov-xml

# Clone the Hyperledger Fabric code and cp sample config files
FABRIC_ROOT=$GOPATH/src/github.com/hyperledger/fabric
cd $GOPATH/src/github.com/hyperledger \
        && wget https://github.com/deevotech/fabric/archive/release-1.2-deevo.zip \
        && unzip release-1.2-deevo.zip \
        && rm release-1.2-deevo.zip \
        && mv fabric-release-1.2-deevo fabric;
#cp $FABRIC_ROOT/devenv/limits.conf /etc/security/limits.conf
cd $FABRIC_ROOT
make dist-clean orderer configtxgen peer

sudo mkdir -p /var/hyperledger
sudo chmod 777 -R /var/hyperledger
