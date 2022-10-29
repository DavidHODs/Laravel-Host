#!/usr/bin/bash

#list of packages needed
packages=('git' 'apache2' 'php8.1-pgsql' 'php8.1-xml' 'php8.1-curl' 'postgresql' 'postgresql-contrib')

log=/home/david/Desktop/AltSchool/2ndSemesterExam/log.log
errorLog=/home/david/Desktop/AltSchool/2ndSemesterExam/error.log

# function to update all packages
function packageUpdate {
    sudo apt-get update -y 
}

function dependenciesInstallation {
    # installs dependencies needed for php8.1
    sudo apt install software-properties-common ca-certificates lsb-release apt-transport-https 
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php 

    # downloads and gives current user executable permission for running laravel composer
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer
}

# loops through the packages in variable packages and installs them
function packageInstallation {
    sudo apt-get install ${packages[@]} -y
}

# iniates the neccessary services of the packages installed
function servicesIniation {
    sudo systemctl start apache2
    sudo systemctl status apache2
    sudo ufw allow 'Apache'
    sudo systemctl start postgresql.service
    sudo systemctl status postgresql.service
}

# checks for errors in the logfile
function errorReport {
    cd /home/david/Desktop/AltSchool/2ndSemesterExam
    echo "Errors Found During Laravel Hosting Operation $(date)" >> ${errorLog}
    echo "+-------------------------------+" >> ${errorLog}
    echo >> ${errorLog}

    grep -i "err" log.log >> ${errorLog}
    echo "+-------------------------------+" >> ${errorLog}

    echo >> ${errorLog}
}

# pulls the laravel app repo to be hosted into apache host directory
# todo: check if altexam exists before operation.
function apacheApp {
    cd
    mkdir AltExam
    cd AltExam
    git init
    git remote add origin https://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@github.com/DavidHODs/laravel-realworld-example-app.git
    git pull origin main
    cd
    sudo mv AltExam /var/www/html/
    cd 
    ls
}

packageUpdate >> ${log}
dependenciesInstallation >> ${log}
packageInstallation >> ${log}
packageUpdate >> ${log}
servicesIniation >> ${log}
apacheApp >> ${log}
errorReport

# sudo -i 
# su - postgres
# psql
# exit;