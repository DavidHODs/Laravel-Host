# Project Goal

Deployment of a Laravel application.

The entire deployment steps including installation of packages and dependencies, configuring of apache webserver etc are defined in an ansible playbook and deployed to an ansible slave.
A bash script is also written that would install and set up postgresql. This bash script would be run on ansible slaves using an ansible playbook <postgres.yml>

## Requirements

The deployment would be accessed using a domain name.
All all the endpoints should be tested without errors.
The base url may or may not display the default Laravel page.
The application must be encrypted with TLS/SSL.

## Results

The application is deployed on an aws ec2 instance and can be accessed via the domain name: <https://davidoluwatobi.me/>
The site is encrypted and does not allow access through http.

The major logics of the project can be found in ops.sh and fine tuned in opsII.sh.
In playbook.yml, opsII.sh was hooked up in ansible. The steps found in opsII.sh are also defined in laravelPlaybook.yml.

Endpoints such as <https://davidoluwatobi.me/api/articles> can also be eaily tested through a web browser.
