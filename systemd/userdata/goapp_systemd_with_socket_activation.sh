#!/bin/bash

APP_NAME="{{.Variables.application_name}}"
SYSTEMD_HOME=/etc/systemd/system

OS=`cat /etc/os-release | grep '^NAME=' |  tr -d \" | sed 's/\n//g' | sed 's/NAME=//g'`
if [ "$OS" == "Ubuntu" ]; then
    USER=ubuntu
    USER_HOME=/home/$USER
elif [ "$OS" == "Debian GNU/Linux" ]; then
    USER=admin
    USER_HOME=/home/$USER
elif [ "$OS" == "Red Hat Enterprise Linux Server" ]; then
    USER=ec2-user
    USER_HOME=/home/$USER
elif [ "$OS" == "CentOS Linux" ]; then
    USER=centos
    USER_HOME=/home/$USER
else
    echo "os $OS unsupported for this script"
    exit 1
fi

APP_PATH=$USER_HOME/go/apps/$APP_NAME
APP_BIN=$APP_PATH/$APP_NAME

mkdir -p $APP_PATH
chown -R $USER:$USER $APP_PATH

/bin/cat > $SYSTEMD_HOME/$APP_NAME.socket <<EOF
[Unit]
Description=Socket for $APP_NAME application

[Socket]
ListenStream=80
NoDelay=true
EOF

/bin/cat > $SYSTEMD_HOME/$APP_NAME.service <<EOF
[Unit]
Description=$APP_NAME (Golang application)
Requires=$APP_NAME.socket
Requires=network.target
After=syslog.target
After=multi-user.target
ConditionPathIsDirectory=$APP_PATH
ConditionFileIsExecutable=$APP_BIN

[Service]
User=$USER
Group=$USER
LimitNOFILE=65536
WorkingDirectory=$APP_PATH
SyslogIdentifier=$APP_NAME
ExecStart=$APP_BIN
# Environment="VALUE"=key
# EnvironmentFile=-/etc/default/$APP_NAME
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

/bin/cat > $USER_HOME/${APP_NAME}_help.txt <<EOF
# Reminder of commands to manage your $APP_NAME
#
# Application location $APP_PATH

# Note that to stop the service you also need to stop the socket. 
# If you don’t stop the socket, incoming connections could auto-start the service

sudo systemctl status $APP_NAME.socket $APP_NAME
sudo systemctl restart $APP_NAME.socket $APP_NAME
sudo systemctl start $APP_NAME.socket $APP_NAME
sudo systemctl stop $APP_NAME.socket $APP_NAME  

# tail logs from application
sudo journalctl -ft $APP_NAME
# tail logs from application and systemd
sudo journalctl -u $APP_NAME

# view/edit service files 
# (run 'sudo systemctl daemon-reload' after editing service files)
vi /etc/systemd/system/$APP_NAME.service 
vi /etc/systemd/system/$APP_NAME.socket 
EOF


systemctl enable $APP_NAME
systemctl daemon-reload
