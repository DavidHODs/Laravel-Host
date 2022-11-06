#!/usr/bin/bash

currentUser=$(whoami)

# function to update all packages
function packageInstall {
    sudo apt-get update -y
    sudo apt install postgresql postgresql-contrib
    sudo systemctl start postgresql.service 
}


function databaseSetUp {
    sudo su - postgres -c \
    "psql <<__END__

        CREATE USER $currentUser;
        ALTER USER $currentUser CREATEDB;

        grant all privileges on database postgres to $currentUser;
        alter user postgres password 'secret';

        select * from information_schema.role_table_grants
        where grantee='""$currentUser""' ;

        CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";
        CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";
        CREATE EXTENSION IF NOT EXISTS \"dblink\";

    __END__
    "
 }

 packageInstall
 databaseSetUp
