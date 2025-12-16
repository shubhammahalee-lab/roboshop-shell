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

yum module disable mysql -y &>>LOGFILE
VALIDATE $? "CentOS-8 Comes with MySQL 8 Version by default, However our application needs MySQL 5.7. So lets disable MySQL 8 version."

cp /home/centos/roboshop-shell/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>>LOGFILE
VALIDATE $? "copy mysql repo "

yum install mysql-community-server -y &>>LOGFILE
VALIDATE $? " mysql "

systemctl enable mysqld
systemctl start mysqld &>>LOGFILE
VALIDATE $? "start mysql service "

mysql_secure_installation --set-root-pass shubham@1 &>>LOGFILE
VALIDATE $? "setup pass "

mysql -uroot -pshubham@1 &>>LOGFILE
VALIDATE $? "check  mysql pass working  "