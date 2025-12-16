<< 'comment'
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

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y


yum module enable redis:remi-6.2 -y

yum install redis -y 

vim /etc/redis.conf

systemctl enable redis

systemctl start redis
comment

#!/bin/bash

########################################
# Variables
########################################
LOGSDIR=/home/centos/shellscript-logs
mkdir -p $LOGSDIR

DATE=$(date +%F_%H-%M-%S)
SCRIPT_NAME=$(basename $0)
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

########################################
# Logging setup (stdout & stderr)
########################################
#exec > >(tee -a $LOGFILE) 2>&1

#echo -e "$Y Script execution started at: $(date) $N"

########################################
# Root validation
########################################
if [ "$(id -u)" -ne 0 ]; then
  echo -e "$R ERROR :: Please run this script as root $N"
  exit 1
fi

########################################
# Validation function
########################################
VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "$R ERROR :: $2 FAILED $N"
    exit 1
  else
    echo -e "$G SUCCESS :: $2 $N"
  fi
}

########################################
# Install Remi Repository
########################################
echo "Installing Remi Repository..."
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOGFILE
VALIDATE $? "Remi repository installation"

########################################
# Enable Redis module
########################################
echo "Enabling Redis module..."
yum module enable redis:remi-6.2 -y &>>$LOGFILE
VALIDATE $? "Redis module enable"

########################################
# Install Redis
########################################
echo "Installing Redis..."
yum install redis -y &>>$LOGFILE
VALIDATE $? "Redis installation"


########################################
# Update Redis config using sed
########################################

# Bind address
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>>$LOGFILE
VALIDATE $? "Updated bind address"

# Protected mode
sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis.conf &>>$LOGFILE
VALIDATE $? "Updated protected-mode"

# Supervised systemd
sed -i 's/^supervised no/supervised systemd/' /etc/redis.conf &>>$LOGFILE
VALIDATE $? "Updated supervised mode"

########################################
# Enable Redis service
########################################
echo "Enabling Redis service..."
systemctl enable redis &>>$LOGFILE
VALIDATE $? "Redis service enable"

########################################
# Start Redis service
########################################
echo "Starting Redis service..."
systemctl start redis &>>$LOGFILE
VALIDATE $? "Redis service start"

########################################
# Verify Redis status
########################################
systemctl is-active redis &>/dev/null &>>$LOGFILE
VALIDATE $? "Redis service running"

echo -e "$G Script execution completed successfully at: $(date) $N"
