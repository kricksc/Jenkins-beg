COMPONENT=redis 
LOG_FILE=/tmp/${COMPONENT}

source ./common.sh 

echo "Install Redis repo on CentOS-8"
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y --skip-broken &>>$LOG_FILE
STATUS_CHECK $?

echo "stop redis.service "
systemctl stop redis &>>$LOG_FILE
STATUS_CHECK $?

echo "enable redis module and install redis"
dnf module enable redis:remi-6.2 -y  &>>$LOG_FILE
yum install redis -y &>>$LOG_FILE
STATUS_CHECK $?

echo "update the bind file"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>>$LOG_FILE
STATUS_CHECK $?

echo "enabling redis and starting redis"
systemctl enable redis &>>$LOG_FILE
STATUS_CHECK $?

echo "starting redis"
systemctl start redis &>>$LOG_FILE
STATUS_CHECK $?