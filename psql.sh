#!/usr/bin/bash


# function to update all packages
function packageInstall {
    sudo apt-get update -y
    sudo apt install postgresql postgresql-contrib
    sudo systemctl start postgresql.service 
}


function databaseSetUp {
    sudo su - postgres -c \
    "psql <<__END__

    SELECT 'crate the same user' ;
        CREATE USER $USER ;
        ALTER USER $USER CREATEDB;

    SELECT 'grant him the priviledges' ;
        grant all privileges on database postgres to $USER ;
        alter user postgres password 'secret';

    SELECT 'AND VERIFY' ;
        select * from information_schema.role_table_grants
        where grantee='""$USER""' ;

    SELECT 'INSTALL EXTENSIONS' ;
        CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";
        CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";
        CREATE EXTENSION IF NOT EXISTS \"dblink\";

    __END__
    "
 }

 packageInstall
 databaseSetUp
