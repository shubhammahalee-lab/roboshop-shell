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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>LOGFILE
VALIDATE $? "rpm install for rabbit mq"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>LOGFILE
VALIDATE $? "rpm package for rabbit mq"

yum install rabbitmq-server -y  &>>LOGFILE
VALIDATE $? "rpm install server for rabbit mq"

systemctl enable rabbitmq-server &>>LOGFILE
VALIDATE $? "rpm enable server for rabbit mq"

systemctl start rabbitmq-server &>>LOGFILE
VALIDATE $? "start service for rabbit mq"

rabbitmqctl add_user roboshop roboshop123 &>>LOGFILE
VALIDATE $? "setup username pass for rabbit mq"


rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>LOGFILE
VALIDATE $? "set permission for rabbit mq"