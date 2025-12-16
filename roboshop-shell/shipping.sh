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


yum install maven -y &>>$LOGFILE
VALIDATE $? "maven"

id roboshop &>/dev/null || useradd roboshop &>>$LOGFILE
VALIDATE $? "creating user"

mkdir -p /app

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE
VALIDATE $? "downloading shipping zip file"

cd /app

unzip /tmp/shipping.zip &>>$LOGFILE
VALIDATE $? "unzip shipping file"

cd /app

mvn clean package &>>$LOGFILE
VALIDATE $? "rune maven goal"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE
VALIDATE $? "move file from target folder"

cp /home/centos/roboshop-shell/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
VALIDATE $? "copy file shipping service"

systemctl daemon-reload
systemctl enable shipping 
systemctl start shipping &>>$LOGFILE
VALIDATE $? "start shipping service"

yum install mysql -y &>>$LOGFILE
VALIDATE $? "mysql"

mysql -h  -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE
VALIDATE $? "get mysql schema"

systemctl restart shipping &>>$LOGFILE
VALIDATE $? "restart service shipping"