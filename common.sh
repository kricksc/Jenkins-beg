STATUS_CHECK() {
    if [$1 -eq 0]; then
    echo -e status ="\e[32Success\e[0m"
    else
    echo -e status ="\e[31Failed\e[0m"
    exit 1
    fi 
    
}
APP_PREREQ() {

    echo "validate to see if the roboshop user exists"
    id roboshop &>>${LOG_FILE}

    if [$? -ne 0]; then
    echo "adding user roboshop to the VM"
    useradd roboshop &>>${LOG_FILE}
    STATUS_CHECK $?
    fi

    echo "Download ${COMPONENT} Application code"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG_FILE}
    STATUS_CHECK $?

    echo "remove old content if exists so as to give the script the ability to re-run "
    cd /home/roboshop && rm -rf ${COMPONENT} &>>${LOG_FILE}
    
    echo "extract the application"
    unzip /tmp/${COMPONENT}.zip &>>${LOG_FILE}
    STATUS_CHECK $?


    mv ${COMPONENT}-main ${COMPONENT} 

}


SYSTEMD_SETUP(){ }


NODEJS() {
    echo "Setup NodeJS on the VM"
    curl -sl https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG_FILE}
    STATUS_CHECK $?

    yum install nodejs -y &>>${LOG_FILE}
    STATUS_CHECK $?

    APP_PREREQ

    echo "Install NodeJS dependencies"

    cd /home/roboshop
    cd ${COMPONENT}
    npm install &>>${LOG_FILE}
    STATUS_CHECK $?
}
JAVA() {}
PYTHON() {}
GOLANG() {}
