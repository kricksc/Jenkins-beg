COMPONENT=rabbittmq
LOG_FILE=/tmp/${COMPONENT}

source ./common.sh 

echo "downlaod Erlang"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>${LOG_FILE}

echo "install erlang"
yum install erlang -y  &>>${LOG_FILE}
STATUS_CHECK $?

echo "setting up YUM repositories for RabbitMQ"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG_FILE}
STATUS_CHECK $?

echo " stopping rabbitmq"
systemctl stop rabbitmq-server  &>>${LOG_FILE}
  
echo "installing rabbitmq"
yum install rabbitmq-server -y  --skip-broken &>>${LOG_FILE}
STATUS_CHECK $?

echo "enabling rabbitmq"
systemctl enable rabbitmq-server  &>>${LOG_FILE}
STATUS_CHECK $?

echo "Starting rabbitmq"
systemctl start rabbitmq-server &>>${LOG_FILE}
STATUS_CHECK $?

rabbitmqctl list_users | grep -i roboshop &>>$LOG_FILE
if [ $? ne 0 ]; then 
    echo "adding roboshop user to rabbitmq"
    rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
    STATUS_CHECK $?
fi 

echo " set roboshop user in rabbitmq as administrator"
rabbitmqctl set_user_tags roboshop administrator &>>$LOG_FILE
STATUS_CHECK $?

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
STATUS_CHECK $?