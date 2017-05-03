#!/bin/bash

# Install awless CLI
curl https://raw.githubusercontent.com/wallix/awless/master/getawless.sh | bash

mv ./awless /usr/local/bin

yum install bash-completion --enablerepo=epel -y

echo 'source <(awless completion bash)' >> /etc/bashrc

# Install awless scheduler daemon
curl https://raw.githubusercontent.com/wallix/awless-scheduler/master/linux_install.sh | bash