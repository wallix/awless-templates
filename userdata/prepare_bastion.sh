#!/bin/bash

export PATH=$PATH:/usr/local/bin

which pip &> /dev/null

if [ $? -ne 0 ] ; then
    echo "PIP NOT INSTALLED"
    [ `which yum` ] && $(yum install -y epel-release; yum install -y python-pip curl) && echo "PIP INSTALLED"
    [ `which apt-get` ] && apt-get -y update && apt-get -y install python-pip curl && echo "PIP INSTALLED"
fi

pip install --upgrade pip &> /dev/null
pip install awscli --ignore-installed six &> /dev/null
easy_install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz

EIP_LIST=""

curl https://s3.amazonaws.com/quickstart-reference/linux/bastion/latest/scripts/bastion_bootstrap.sh | bash -s -- --tcp-forwarding true --enable false