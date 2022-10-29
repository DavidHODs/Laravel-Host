#!/usr/bin/bash

#list of packages needed
packages=('git' 'apache2' 'php8.1-pgsql' 'php8.1-xml' 'php8.1-curl' 'postgresql' 'postgresql-contrib')

log=/home/david/Desktop/AltSchool/2ndSemesterExam/log.log


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

function packageInstallation {
    sudo apt-get install ${packages[@]} -y
}

function servicesIniation {
    sudo systemctl start apache2
    sudo systemctl status apache2
    sudo ufw allow 'Apache'
    sudo systemctl start postgresql.service
    sudo systemctl status postgresql.service
}

packageUpdate >> ${log}
dependenciesInstallation >> ${log}
packageInstallation >> ${log}
packageUpdate >> ${log}
servicesIniation >> ${log}