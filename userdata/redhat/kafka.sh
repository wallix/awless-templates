#!/bin/bash

yum -y install unzip java wget

curl -O https://raw.githubusercontent.com/wallix/awless/master/getawless.sh
/bin/bash getawless.sh
mv awless /usr/local/bin

ZOOKEEPER_IP=$(/usr/local/bin/awless ls instances --filter name=zookeeper --format csv | tail -1 | cut -d, -f6)

KAFKA_DOWNLOAD=kafka_2.12-0.10.2.1

wget http://apache.mediamirrors.org/kafka/0.10.2.1/$KAFKA_DOWNLOAD.tgz

tar -zxvf $KAFKA_DOWNLOAD.tgz -C /opt
ln -s /opt/$KAFKA_DOWNLOAD /opt/kafka

mkdir /tmp/kafka-logs

sed -i.bak "s_zookeeper.connect=.*_zookeeper.connect=$ZOOKEEPER_IP:2181_g" /opt/kafka/config/server.properties

nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /dev/null 2>&1 &