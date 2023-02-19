ID=$(id -u)

if [ $ID -ne 0 ]; then 
    echo "you are not running as root and this will fail"
    exit 1
fi 



STATUS_CHECK(){
    if [ $1 -eq 0 ]; then
    echo -e status ="\e[32Success\e[0m"
    else
    echo -e status ="\e[31Failed\e[0m"
    exit 1
    fi 
    
}
APP_PREREQ() {

    echo "validate to see if the roboshop user exists"
    id roboshop &>>${LOG_FILE}

    if [ $? -ne 0 ]; then
    echo "adding user roboshop to the VM"
    useradd roboshop &>>${LOG_FILE}
    STATUS_CHECK $?
    fi

    echo "Download ${COMPONENT} Application code"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG_FILE}
    STATUS_CHECK $?


    echo "stoping the service before cleanup"
    systemctl stop ${COMPONENT}.service 

    echo "remove old content if exists so as to give the script the ability to re-run "
    cd /home/roboshop && rm -rf ${COMPONENT} &>>${LOG_FILE}
    
    echo "extract the application"
    unzip /tmp/${COMPONENT}.zip &>>${LOG_FILE}
    STATUS_CHECK $?


    mv ${COMPONENT}-main ${COMPONENT} 

    
    cd /home/roboshop
    cd ${COMPONENT}

}


SYSTEMD_SETUP() {
    echo "updating the systemD service file with DNS name"
     sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' -e 's/CARTHOST/cart.roboshop.internal/' -e 's/USERHOST/user.roboshop.internal/' -e  's/AMQPHOST/rabbittmq.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service &>>${LOG_FILE}
    
    echo "setting the service to run"
    mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
    STATUS_CHECK $?

    echo "reloading the config from disk"
    systemctl daemon-reload &>>${LOG_FILE}
    STATUS_CHECK $?

    echo "starting the service"
    systemctl start ${COMPONENT} &>>${LOG_FILE}
    STATUS_CHECK $?

    echo "enable the service"
    systemctl enable ${COMPONENT} &>>${LOG_FILE}
    STATUS_CHECK $?

    }


NODEJS() {
    echo "Setup NodeJS on the VM"
    curl -sl https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG_FILE}
    STATUS_CHECK $?

    yum install nodejs -y &>>${LOG_FILE}
    STATUS_CHECK $?

    APP_PREREQ

    echo "installing NodeJS dependencies"
    npm install &>>${LOG_FILE}
    STATUS_CHECK $?

    SYSTEMD_SETUP


}
