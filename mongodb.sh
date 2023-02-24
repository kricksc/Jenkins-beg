COMPONENT=mongodb 
LOG_FILE=/tmp/${COMPONENT}
source ./common.sh 

echo "Dowloading mongodb repo"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>${LOG_FILE}
STATUS_CHECK $?

echo "stop mongodb"
systemctl stop mongod  &>>${LOG_FILE}

echo "installing mongodb"
yum install -y mongodb-org &>>${LOG_FILE}
STATUS_CHECK $?

echo "enabling mongod"
systemctl enable mongod &>>${LOG_FILE}
STATUS_CHECK $?

echo "starting mongod" &>>${LOG_FILE}
STATUS_CHECK $?

echo "updating IP in Config file"
sed -i -e 's/127.0.0.1/0.0.0.0 /' /etc/mongod.conf &>>${LOG_FILE}
STATUS_CHECK $?

echo "restarting the system"
systemctl restart mongod &>>${LOG_FILE}
STATUS_CHECK $?


echo "downloading the schema"
rm -rf /tmp/mongodb.zip
rm -rf /tmp/mongodb-main
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>${LOG_FILE}
STATUS_CHECK $?

echo"changing directory to temp"
cd /tmp &>>${LOG_FILE}
STATUS_CHECK $?

echo "unziping the directory"
unzip mongodb.zip &>>${LOG_FILE}
STATUS_CHECK $?

echo "change directory to mongodb-main"
cd mongodb-main &>>${LOG_FILE}
STATUS_CHECK $?

mongo < catalogue.js &>>${LOG_FILE}
STATUS_CHECK $?

mongo < users.js &>>${LOG_FILE}
STATUS_CHECK $?