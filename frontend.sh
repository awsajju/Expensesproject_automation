#!/bin/bash
#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER=/var/log/frontend.log
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

dnf install nginx -y &>>$LOG_FILE_NAME

validate $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE_NAME

validate $? "Enabling nginx"

systemctl start nginx &>>$LOG_FILE_NAME

validate $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME

validate $? "removing the existing code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip

vlidate $? "dowloading code"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
validate $? "movbie to html directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
validate $? "unziping the frontend code"

systemctl restart nginx &>>$LOG_FILE_NAME
validate $? "restarting nginx server"