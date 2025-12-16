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

yum install golang -y &>>LOGFILE
VALIDATE $? "instaling golang"

id roboshop &>/dev/null || useradd roboshop &>>$LOGFILE
VALIDATE $? "creating user"

mkdir -p /app

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>LOGFILE
VALIDATE $? "downloading dispatch zip"

cd /app &>>LOGFILE
VALIDATE $? "go to app directory"

unzip /tmp/dispatch.zip &>>LOGFILE
VALIDATE $? "unzip folder"

cd /app &>>LOGFILE
VALIDATE $? "come to app folder"

go mod init dispatch &>>LOGFILE
VALIDATE $? "go init"

go get &>>LOGFILE
VALIDATE $? "get go"

go build &>>LOGFILE
VALIDATE $? "build go"

cp /home/centos/roboshop-shell/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>>LOGFILE
VALIDATE $? "copy  dispatch service"

systemctl daemon-reload &>>LOGFILE

systemctl enable dispatch &>>LOGFILE

systemctl start dispatch &>>LOGFILE
VALIDATE $? "start dispatch"
