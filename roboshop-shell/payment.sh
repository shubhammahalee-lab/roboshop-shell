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

yum install python36 gcc python3-devel -y &>>LOGFILE
VALIDATE $? "install python"

id roboshop &>/dev/null || useradd roboshop &>>$LOGFILE
VALIDATE $? "creating user"

mkdir -p /app

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE
VALIDATE $? "get payment zip file"

cd /app &>>$LOGFILE
VALIDATE $? "goto app directory"

unzip /tmp/payment.zip &>>$LOGFILE
VALIDATE $? "unzip file"

cd /app &>>$LOGFILE
VALIDATE $? "goto app directory"


pip3.6 install -r requirements.txt &>>$LOGFILE
VALIDATE $? "install requirement"

cp /home/centos/roboshop-shell/roboshop-shell/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? "copy payment service"


systemctl daemon-reload
systemctl enable payment 
systemctl start payment &>>$LOGFILE
VALIDATE $? "start payment service"