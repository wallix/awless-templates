#!/bin/bash

curl https://raw.githubusercontent.com/wallix/awless/master/getawless.sh | bash

mv ./awless /usr/local/bin

yum install bash-completion --enablerepo=epel -y

echo 'source <(awless completion bash)' >> /etc/bashrc