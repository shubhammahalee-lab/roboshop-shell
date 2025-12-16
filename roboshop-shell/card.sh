#!/bin/bash

LOGSDIR=/home/centos/shellscript-logs
mkdir -p $LOGSDIR

DATE=$(date +%F_%H-%M-%S)
SCRIPT_NAME=$(basename $0)
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
N="\e[0m"

if [ "$(id -u)" -ne 0 ]; then
  echo -e "$R ERROR :: Run as root $N"
  exit 1
fi

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "Installing $2 :: $R FAILED $N"
    exit 1
  else
    echo -e "Installing $2 :: $G SUCCESS $N"
  fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
VALIDATE $? "NodeJS repo setup"

yum install nodejs -y &>>$LOGFILE
VALIDATE $? "NodeJS install"

id roboshop &>/dev/null || useradd roboshop &>>$LOGFILE

mkdir -p /app

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip
VALIDATE $? "downloading cart.zip"

cd /app || exit 1

unzip -o /tmp/cart.zip &>>$LOGFILE
VALIDATE $? "Unzip cart.zip"

cd /app 

npm install &>>$LOGFILE
VALIDATE $? "NPM install"

cp /home/centos/roboshop-shell/roboshop-shell/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copy service file"

systemctl daemon-reload &>>$LOGFILE

systemctl enable cart &>>$LOGFILE

systemctl start cart &>>$LOGFILE

VALIDATE $? "card service start"