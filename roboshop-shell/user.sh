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
VALIDATE $? "rmi repo intalled"

yum install nodejs -y &>>$LOGFILE
VALIDATE $? "install nodejs"

id roboshop &>/dev/null || useradd roboshop &>>$LOGFILE

mkdir -p /app

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE
VALIDATE $? "downloading user.zip"

cd /app &>>$LOGFILE
VALIDATE $? "goto app directory "

unzip /tmp/user.zip &>>$LOGFILE
VALIDATE $? "unzip file"

cd /app &>>$LOGFILE
VALIDATE $? "goto app directory"

npm install  &>>$LOGFILE
VALIDATE $? "npm install"

cp /home/centos/roboshop-shell/roboshop-shell/user.service /etc/systemd/system/user.service &>>$LOGFILE
VALIDATE $? "copy user.service"

systemctl daemon-reload &>>$LOGFILE

systemctl enable user  &>>$LOGFILE

systemctl start user &>>$LOGFILE
VALIDATE $? "start user service"

cp /home/centos/roboshop-shell/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
VALIDATE $? "copy mongo.repo"

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "instaling mongod client"

mongo --host 172.31.27.74 </app/schema/user.js &>>$LOGFILE