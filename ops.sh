#!/usr/bin/bash

#list of packages needed
packages=('git' 'apache2' 'php8.1' 'php8.1-mysql' 'php8.1-xml' 'php8.1-curl' 'mysql-server')

log=~/Laravel-Host/log.log
errorLog=~/Laravel-Host/error.log

# returns the first ip address (included this logic because my system returned multiple ip addresses)
host_ip=$(hostname -i)
host=${host_ip[0]}

key=`cat ~/Laravel-Host/.key`

# function to update all packages
function packageUpdate {
    sudo apt-get update -y && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y
}

function dependenciesInstallation {
    # installs dependencies needed for php8.1
    sudo apt install software-properties-common ca-certificates lsb-release apt-transport-https 
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php 
}

# downloads and gives current user executable permission for running laravel composer
function composerInstallation {
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
    sudo systemctl start mysql.service
    sudo systemctl status mysql.service
}

# checks for errors in the logfile
function errorReport {
    cd ~/Laravel-Host/
    if grep -i "err" log.log | grep -i "warning" log.log; then
        echo "Errors Found During Laravel Hosting Operation $(date) for ${host}" >> ${errorLog}
        echo "+-------------------------------+" >> ${errorLog}
        echo >> ${errorLog}

        grep -i "err" log.log >> ${errorLog}
        grep -i "warning" log.log >> ${errorLog}
        echo "+-------------------------------+" >> ${errorLog}

        echo >> ${errorLog}
    fi
}

# pulls and moves the laravel app repo to be hosted into apache host directory
function gitOp {
    cd ~

    # checks if laravel-realworld-example-app folder exists in apache html directory before deleting it
    if [ -d /var/www/html/laravel-realworld-example-app ]; then
        sudo rm -rf /var/www/html/laravel-realworld-example-app
    fi
    
    # moves laravel-realworld-example-app folder containing the app to be hosted into apache html directory
    sudo mv ~/laravel-realworld-example-app /var/www/html/ 
}

# function databaseSetUp {
    
# }

# apacheConf formats the contents of apache conf file with the propoer host ip address
function apacheConf {
    export host=${host}
    envsubst '$host' < ~/Laravel-Host/conf.txt > ~/Laravel-Host/laravel_project.conf
}

# apacheOp executes logics for the actual app hosting
function apacheOp {
     cd ~

    # checks if laravel-realworld-example-app folder exists in apache html directory before deleting it
    if [ -d /var/www/html/laravel-realworld-example-app ]; then
        sudo rm -rf /var/www/html/laravel-realworld-example-app
    fi

    cd /var/www/html/laravel-realworld-example-app
    composer update
    composer create-project

    sudo chgrp -R www-data /var/www/html/laravel-realworld-example-app/
    sudo chmod -R 775 /var/www/html/laravel-realworld-example-app/storage

    sudo php artisan key:generate
    sudo php artisan migrate

    # checks if project conf file exists
    if [ -f /etc/apache2/sites-available/laravel_project.conf ]; then
        sudo rm -rf /etc/apache2/sites-available/laravel_project.conf
    fi

    sudo cp ~/Laravel-Host/laravel_project.conf /etc/apache2/sites-available/

    cd /etc/apache2/sites-available

    # disables the default configuration file of the virtual hosts in Apache
    sudo a2dissite 000-default.conf

    # enables the new virtual host:
    sudo a2ensite laravel_project

    # enables the Apache rewrite module and restarts the Apache service
    sudo a2enmod rewrite
    sudo systemctl restart apache2
}

# brainBox calls the created functions
function brainBox {
    packageUpdate
    dependenciesInstallation
    packageInstallation
    composerInstallation
    packageUpdate
    servicesIniation
    gitOp
    apacheConf
    apacheOp
}
brainBox >> ${log}
errorReport