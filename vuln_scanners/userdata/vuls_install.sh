#!/bin/bash

OS=`cat /etc/os-release | grep '^NAME=' |  tr -d \" | sed 's/\n//g' | sed 's/NAME=//g'`
if [ "$OS" == "Ubuntu" ]; then
    USER=ubuntu
    USER_HOME=/home/$USER
    PROFILE_PATH=$USER_HOME/.profile
    apt-get -y install sqlite3 git gcc make curl build-essential
elif [ "$OS" == "Debian GNU/Linux" ]; then
    USER=admin
    USER_HOME=/home/$USER
    PROFILE_PATH=$USER_HOME/.profile
    apt-get -y install sqlite3 git gcc make curl
elif [ "$OS" == "Amazon Linux AMI" ]; then
    USER=ec2-user
    USER_HOME=/home/$USER
    PROFILE_PATH=$USER_HOME/.bash_profile
    yum -y install sqlite git gcc make curl
elif [ "$OS" == "Red Hat Enterprise Linux Server" ]; then
    USER=ec2-user
    USER_HOME=/home/$USER
    PROFILE_PATH=$USER_HOME/.bash_profile
    yum -y install sqlite git gcc make curl
elif [ "$OS" == "CentOS Linux" ]; then
    USER=centos
    USER_HOME=/home/$USER
    PROFILE_PATH=$USER_HOME/.bash_profile
    yum -y install sqlite git gcc make curl
else
    echo "os $OS unsupported for this script"
    exit 1
fi

# Golang install
GO_VERSION=1.9.4
TAR_FILE=go$GO_VERSION.linux-amd64.tar.gz
curl -O https://dl.google.com/go/$TAR_FILE
tar -C /usr/local -xzf $TAR_FILE; rm $TAR_FILE

# For root
mkdir $HOME/go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# Required dirs
mkdir -p /var/log/vuls
chown $USER /var/log/vuls
mkdir -p $GOPATH/src/github.com/kotakanbe
mkdir $GOPATH/src/github.com/future-architect

# CVE dictionnary
cd $GOPATH/src/github.com/kotakanbe
git clone https://github.com/kotakanbe/go-cve-dictionary.git
cd go-cve-dictionary
make install

# Oval dictionnary
cd $GOPATH/src/github.com/kotakanbe
git clone https://github.com/kotakanbe/goval-dictionary.git
cd goval-dictionary
make install

# Install Vuls
cd $GOPATH/src/github.com/future-architect
git clone https://github.com/future-architect/vuls.git
cd vuls
make install

# Moving Go resources to USER_HOME (as cloud-init executes a root)
mkdir $USER_HOME/go
cp -R $GOPATH/* $USER_HOME/go
echo "export GOPATH=\$HOME/go" >> $PROFILE_PATH
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> $PROFILE_PATH

# Generate SSH key for remotes scans. Public key need to be added to ~/.ssh/authorized_keys on remote hosts to be scanned 
ssh-keygen -t rsa -N "" -f $USER_HOME/.ssh/id_rsa

# Prepare toml local files for remote scans
/bin/cat > $USER_HOME/config.toml <<EOF
[servers]

[servers.localhost]
host        = "localhost"
port        = "local"

# [servers.debian]
# host      = "..."    # remote host address
# port      = "22"     # for remote ssh scans
# user      = "admin"  # user for remote ssh scans
# keyPath   = "$USER_HOME/.ssh/id_rsa" # Local priv key to SSH connect to scanned target. Targets need to have pub key in their ~/.ssh/authorized_keys
EOF

FETCH_DATA_FILENAME=fetch-nvd-oval-cve-data.sh
/bin/cat > $USER_HOME/$FETCH_DATA_FILENAME <<EOF
source $PROFILE_PATH

# Fetch vulnerability data from NVD
# Takes about 10 minutes
for i in \`seq 2002 $(date +\"%Y\")\`; do go-cve-dictionary fetchnvd -years \$i; done

# Fetch OVAL data for some commonf distro (or what os need to be scanned)
goval-dictionary fetch-debian 7 8 9 10
goval-dictionary fetch-ubuntu 12 14 16
EOF

chmod +x $USER_HOME/$FETCH_DATA_FILENAME
# Since we created files as root and moved root resource to USER_HOME
chown -R $USER:$USER $USER_HOME
