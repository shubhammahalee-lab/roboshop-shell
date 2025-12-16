<< 'COMMENT1'
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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE $? "successfully get node js setup"

yum install nodejs -y &>>$LOGFILE

VALIDATE $? "get nodejs"

useradd roboshop &>>$LOGFILE
if [ $? -eq 1 ];then
echo "user already exists"
fi

VALIDATE $? "adding user"

mkdir /app &>>$LOGFILE
if [ $? -eq 1 ];then
echo "directory already exists"
fi
VALIDATE $? "creating directory for application"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE

VALIDATE $? "get application"

cd /app 

VALIDATE $? " go to app directory"

unzip /tmp/catalogue.zip &>>$LOGFILE

VALIDATE $? "unzip directory for application"

cd /app &>>$LOGFILE

VALIDATE $? "goto app directory for application"

npm install &>>$LOGFILE

VALIDATE $? "npm for application"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "reaload deamon for application"

systemctl enable catalogue &>>$LOGFILE

VALIDATE $? "enable service for application"

systemctl start catalogue &>>$LOGFILE

VALIDATE $? "start service for application"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "copy mongo.repo for application"

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "mongoclient  for application"

mongo --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js &>>$LOGFILE

VALIDATE $? "enabling catalogue for application"

COMMENT1


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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE
VALIDATE $? "Download catalogue"

cd /app || exit 1
unzip -o /tmp/catalogue.zip &>>$LOGFILE
VALIDATE $? "Unzip catalogue"

npm install &>>$LOGFILE
VALIDATE $? "NPM install"

cp /home/centos/roboshop-shell/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE
VALIDATE $? "Copy service file"

systemctl daemon-reload &>>$LOGFILE
systemctl enable catalogue &>>$LOGFILE
systemctl start catalogue &>>$LOGFILE
VALIDATE $? "Catalogue service start"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
yum install mongodb-org-shell -y &>>$LOGFILE

mongo --host 172.31.27.74 </app/schema/catalogue.js &>>$LOGFILE
VALIDATE $? "Mongo schema load"

