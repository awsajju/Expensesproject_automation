#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER=/var/log/backend.log
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP"

validate(){
    if [ $1 -ne 0 ];then
        echo -e "$2 $R fialure $N"
        exit 1
    else
        echo -e "$2 $G Success $N"
    fi
}

Check_Out(){
    if [ $? -ne 0 ];then
        echo "You must have the sudo access to execute this"
        exit 1
    fi
}

echo "script started executing at $TIMESTAMP" &>>$LOG_FILE_NAME

Check_Out

dnf module disable nodejs -y &>>$LOG_FILE_NAME
validate $? "disabling current nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
validate $? "enabling nodejs 20"

dnf install nodejs -y &>>$LOG_FILE_NAME
validate $? "installing nodejs"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ];then
    useradd expense &>>$LOG_FILE_NAME
    validate $? "adding expenses user"
else
    echo -e "expenser user already exists"
fi

mkdir -p /app &>>$LOG_FILE_NAME

validate $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
validate $? "Downloading backend"

cd /app
rm -rf /app/*

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
validate $? "unzip backend"

npm install &>>$LOG_FILE_NAME
validate $? "installing dependencies"

cp /home/ec2-user/Expensesproject_automation/backend.service /etc/systemd/system/backend.service

# prepare MYSQL Schema

dnf install mysql -y &>>$LOG_FILE_NAME
validate $? "installing mysql"

mysql -h mysql.myfooddy.fun -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
validate $? "Setting up transaction schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
validate $? "Daemon reloading"

systemctl enable backend &>>$LOG_FILE_NAME
validate $? "Enabling backend"

systemctl restart backend &>>$LOG_FILE_NAME
validate $? "start backend"