#!/bin/bash

LOGSDIR=/home/centos/shellscript-logs
mkdir -p $LOGSDIR
 
DATE=$(date +%F_%H-%M-%S)
SCRIPT_NAME=$(basename $0)

LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

USERCHECK=$(id -u)

if [ "$USERCHECK" -ne 0 ]
then
    echo -e "$R ERROR :: please run this in the root access $N"
    exit 1
fi

VALIDATE(){

    if [ $1 -ne 0 ]
    then 
        echo -e " instaling $2 :: $R FAILED $N"
        exit 1
    else
        echo -e " instaling $2 :: $G success $N"
    fi

}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>LOGFILE

VALIDATE $? "copy mongo.repo into yum.repos.d"

yum install mongodb-org -y &>>LOGFILE

VALIDATE $? "mongodb-org"

systemctl enable mongod &>>LOGFILE

VALIDATE $? "enabling mongod"

systemctl start mongod &>>LOGFILE

VALIDATE $? "starting mongod"

sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf &>>LOGFILE

VALIDATE $? "Updating mongod.conf"

systemctl restart mongod &>>LOGFILE

VALIDATE $? "RE-starting mongod"

