#!/bin/bash

apt-get -y install haproxy

curl https://raw.githubusercontent.com/wallix/awless/master/getawless.sh | bash

NODE_1_IP=$(./awless ls instances --filter name=cockroachdb-node-1 --filter state=run --format csv | tail -1 | cut -d, -f7)
NODE_2_IP=$(./awless ls instances --filter name=cockroachdb-node-2 --filter state=run --format csv | tail -1 | cut -d, -f7)
NODE_3_IP=$(./awless ls instances --filter name=cockroachdb-node-3 --filter state=run --format csv | tail -1 | cut -d, -f7)

rm awless

/bin/cat > haproxy.cfg <<EOF
global
  maxconn 4096

defaults
    mode                tcp
    timeout connect     10s
    timeout client      1m
    timeout server      1m

listen psql
    bind :26257
    mode tcp
    balance roundrobin
    server cockroach1 $NODE_1_IP:26257
    server cockroach2 $NODE_2_IP:26257
    server cockroach3 $NODE_3_IP:26257

listen ui
    bind :80
    mode http
    balance roundrobin
    server cockroachui1 $NODE_1_IP:8080
    server cockroachui2 $NODE_2_IP:8080
    server cockroachui3 $NODE_3_IP:8080
EOF

service haproxy stop

mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
mv haproxy.cfg /etc/haproxy/haproxy.cfg

service haproxy start