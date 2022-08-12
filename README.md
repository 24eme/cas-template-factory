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

##Dockerization

### Build image

    sudo docker build . --build-arg cas_templatespath=templates/path --build-arg ldap_domain=example.org --build-arg ldap_passwd=adminpassword  --build-arg ldap_test_username=test

### Run container

    sudo docker run -it -p 8080:80 -p 389:389 <IMAGE_ID>