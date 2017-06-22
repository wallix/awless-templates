#!/bin/bash

curl https://raw.githubusercontent.com/wallix/awless/master/getawless.sh | bash

FIRST_NODE_IP=$(./awless ls instances --filter name=cockroachdb-node-1 --filter state=run --format csv | tail -1 | cut -d, -f7)

rm awless

PACKAGE=cockroach-v1.0.2.linux-amd64

curl -O https://binaries.cockroachdb.com/$PACKAGE.tgz

tar -xf $PACKAGE.tgz --strip=1 $PACKAGE/cockroach

mv cockroach /usr/bin

INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cockroach start --insecure --background --join=$FIRST_NODE_IP:26257 --advertise-host=$INSTANCE_IP --http-host=$INSTANCE_IP --host=$INSTANCE_IP