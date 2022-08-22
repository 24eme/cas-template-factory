# APEREO/CAS template factory

## Clone cas overlay template project 

    git clone https://github.com/apereo/cas-overlay-template.git

## Add at the end of `cas-overlay-template/build.gradle` :


    dependencies { 
    	implementation "org.apereo.cas:cas-server-support-ldap:${project.'cas.version'}"
    	implementation "org.apereo.cas:cas-server-support-json-service-registry:${project.'cas.version'}"
    	implementation "org.apereo.cas:cas-server-support-generic:${project.'cas.version'}"
    }

## Check java version in `cas-overlay-template/gradle.properties` :

    sourceCompatibility=11
    targetCompatibility=11

## Create configuration directory

    mkdir -p /etc/cas/config

## Copy and adapt the configuration

    cp config/cas.properties config/log4j.xml /etc/cas/config

## Link to the templates you want

    ln -s $(pwd)/templates/bivc/templates /etc/cas
    ln -s $(pwd)/templates/bivc/static /etc/cas

## Build a cas war

    cd cas-overlay-template
    ./gradlew clean build

## Put your war on tomcat and restart it

    cp build/libs/cas.war /var/lib/tomcat*/webapps/
    service tomcat restart

## Alternatively you can run cas via gradle

    ./gradlew createKeystore
    ./gradlew run

The cas is available on https://localhost:8443/ (accept the autosigned certificate)

## Dockerization

### Build image

    sudo docker build . -t cas_viticonnect --build-arg cas_templatespath=templates/path --build-arg ldap_domain=example.org --build-arg ldap_passwd=adminpassword  --build-arg ldap_test_username=test --build-arg ldap_test_password=test --build-arg viticonnect_shared_secret=SHAREDSECRET

with the `build-arg`:

 - `cas_templatespath`: the path to a directory containing the static Apereo/CAS files (subdirectory `static`) and the Thymeleaf template files (subdirectories `templates/fragments`, `templates/login`, `templates/logout`). Examples are provided in [templates/](templates/).
 - `ldap_domain`: the ldap domain
 - `ldap_passwd`: the password for the ldap administrator (in clear text)
 - `ldap_test_username`: a test login to create
 - `ldap_test_password`: the password to create for the test user
 - `viticonnect_shared_secret`: the shared secret allowing viticonnect to query the api

### Run container

    sudo docker run -it -p 8080:80 -p 389:389 -v /data/ldap:/var/lib/ldap cas_viticonnect

## Viticonnect API

Client Viticonnect API provides to the viticonnect server the following identifiers : SIRET, CVI, Accises, PPM, TVA Number and a "Raison sociale"

By default, the simple client viticonnect api retrives these identifiers form the following LDAP fields :

 - Raison sociale: `sn`
 - SIRET: `telephoneNumber`
 - TVA: `o`
 - CVI: `description`
 - Accises: `street`
 - PPM: `facsimileTelephoneNumber`

A bash script creates users using this fields : `bin/createuser4viticonnectldap.sh` (create before `bin/config.inc` from `bin/config.inc.example`)

If you want to change the ldap field used by viticonnect, you can edit `viticonnect/config.php` and `bin/config.inc`
