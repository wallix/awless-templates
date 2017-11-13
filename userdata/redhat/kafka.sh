#!/bin/bash

yum -y install java

curl https://raw.githubusercontent.com/wallix/awless/master/getawless.sh | bash
mv awless /usr/bin

ZOOKEEPER_IP=$(/usr/bin/awless ls instances --filter name=zookeeper --filter state=run --format csv | tail -1 | cut -d, -f7)

KAFKA_DOWNLOAD=kafka_2.12-1.0.0

curl -O http://apache.mediamirrors.org/kafka/1.0.0/$KAFKA_DOWNLOAD.tgz

tar -zxvf $KAFKA_DOWNLOAD.tgz -C /opt
ln -s /opt/$KAFKA_DOWNLOAD /opt/kafka

mkdir /tmp/kafka-logs

INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
BROKER_ID=$(/usr/bin/awless ls instances --filter name=broker --sort name --format tsv --no-headers | grep $INSTANCE_ID -n | cut -d: -f1)

sed -i "s/zookeeper.connect=.*/zookeeper.connect=$ZOOKEEPER_IP:2181/" /opt/kafka/config/server.properties
sed -i "s/broker.id=.*/broker.id=$BROKER_ID/" /opt/kafka/config/server.properties
sed -i "s_#listeners=PLAINTEXT://:9092_listeners=PLAINTEXT://$INSTANCE_IP:9092_" /opt/kafka/config/server.properties

nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /dev/null 2>&1 &