#!/bin/bash

apt-get -y install bash-completion git

curl https://raw.githubusercontent.com/wallix/awless/master/getawless.sh | bash
mv awless /usr/bin

sed -i "$ a\\source <(awless completion bash)" /etc/bash.bashrc

curl https://raw.githubusercontent.com/wallix/awless-scheduler/master/linux_install.sh | bash