#!/bin/bash

yum -y install java

KAFKA_DOWNLOAD=kafka_2.12-0.10.2.1

curl -O http://apache.mediamirrors.org/kafka/0.10.2.1/$KAFKA_DOWNLOAD.tgz

tar -zxvf $KAFKA_DOWNLOAD.tgz -C /opt
ln -s /opt/$KAFKA_DOWNLOAD /opt/kafka

nohup /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties > /dev/null 2>&1 &