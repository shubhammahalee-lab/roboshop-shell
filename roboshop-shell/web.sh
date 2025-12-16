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

yum install nginx -y &>>LOGFILE

systemctl enable nginx &>>LOGFILE

systemctl start nginx &>>LOGFILE

rm -rf /usr/share/nginx/html/* &>>LOGFILE

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>LOGFILE

cd /usr/share/nginx/html &>>LOGFILE

unzip /tmp/web.zip &>>LOGFILE

cp /home/centos/roboshop-shell/roboshop-shell/roboshop.conf  /etc/nginx/default.d/roboshop.conf &>>LOGFILE

systemctl restart nginx &>>LOGFILE