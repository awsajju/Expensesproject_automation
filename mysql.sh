#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER=/var/log/Expenseproject_db.log
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"

Check_Out(){
    if [ $USERID -ne 0 ];then
        echo -e "You must have the sudo access to exute"
        exit 1
    fi
}

echo "script started executing at $TIMESTAMP" &>>$LOG_FILE_NAME

Check_Out

Validate(){
    if [ $1 -ne 0 ];then 
    
        echo -e "$2 Installing package is --> $R failure $N" &>>$LOG_FILE_NAME
        exit 1
    else 
        echo -e "$2 installing package is --->$G Success $N" &>>$LOG_FILE_NAME
    fi
    
}

dnf install mysql-server -y &>>$LOG_FILE_NAME
 Validate $? "installing msql-serever"

systemctl enable mysqld &>>$LOG_FILE_NAME

Validate $? "Enabling mysqld server"

systemctl start mysqld &>>$LOG_FILE_NAME
Validate $? "Starting mysql server"

mysql -h myfooddy.fun -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME

if [ $? -ne 0 ];then
    echo "MYSQL root password not setup" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    Validate $? "setting root password"
else
    echo -e "MYSQL root password already setup $Y skipping $N"
fi
    









