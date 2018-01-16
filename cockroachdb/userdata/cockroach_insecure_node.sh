#!/bin/bash

apt-get -y install ntp

PACKAGE=cockroach-v1.1.4.linux-amd64

curl -O https://binaries.cockroachdb.com/$PACKAGE.tgz

tar -xf $PACKAGE.tgz --strip=1 $PACKAGE/cockroach

mv cockroach /usr/bin

INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cockroach start --insecure --background --advertise-host=$INSTANCE_IP --http-host=$INSTANCE_IP --host=$INSTANCE_IP