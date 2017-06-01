#!/bin/bash

yum -y install unzip java wget

curl -O https://raw.githubusercontent.com/wallix/awless/master/getawless.sh
/bin/bash getawless.sh
mv awless /usr/local/bin

ZOOKEEPER_IP=$(/usr/local/bin/awless ls instances --filter name=zookeeper --format csv | tail -1 | cut -d, -f7)

echo "Resolved Zookeeper private IP is $ZOOKEEPER_IP"

KAFKA_DOWNLOAD=kafka_2.12-0.10.2.1

wget http://apache.mediamirrors.org/kafka/0.10.2.1/$KAFKA_DOWNLOAD.tgz

tar -zxvf $KAFKA_DOWNLOAD.tgz -C /opt
ln -s /opt/$KAFKA_DOWNLOAD /opt/kafka

mkdir /tmp/kafka-logs

INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
BROKER_ID=$(/usr/local/bin/awless ls instances --filter name=broker --sort name --format tsv | tail -n +2 | grep $INSTANCE_ID -n | cut -d: -f1)

sed -i.bak "s/zookeeper.connect=.*/zookeeper.connect=$ZOOKEEPER_IP:2181/g" /opt/kafka/config/server.properties
sed -i.bak "s/broker.id=.*/broker.id=$BROKER_ID/g" /opt/kafka/config/server.properties

nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /dev/null 2>&1 &