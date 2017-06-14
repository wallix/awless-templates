#!/bin/bash

apt-get -y install unzip bash-completion vim git

curl -O "https://raw.githubusercontent.com/wallix/awless/master/getawless.sh"
/bin/bash getawless.sh
mv awless /usr/bin

sed -i "$ a\\source <(awless completion bash)" /etc/bash.bashrc

curl -O "https://raw.githubusercontent.com/wallix/awless-scheduler/master/linux_install.sh"
/bin/bash linux_install.sh