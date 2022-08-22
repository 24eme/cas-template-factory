FROM debian:11
MAINTAINER tmorlier@24eme.fr

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

ARG ldap_passwd
ARG ldap_domain
ARG ldap_test_username
ARG ldap_test_password
ARG cas_templatespath
ARG viticonnect_shared_secret

RUN echo slapd   slapd/password1 password    $ldap_passwd | debconf-set-selections && \
    echo slapd   slapd/password2 password    $ldap_passwd | debconf-set-selections && \
    echo slapd   slapd/domain    string  $ldap_domain | debconf-set-selections && \
    echo slapd   shared/organization string  $ldap_domain | debconf-set-selections

RUN apt-get update && \
    apt-get install -q -y default-jre tomcat9 git ldap-utils slapd libapache2-mod-php rsync php-ldap && \
    apt-get clean

COPY docker/apache2.conf /etc/apache2/sites-enabled/001-cas.conf
RUN a2enmod proxy_http && a2enmod rewrite && service apache2 restart

RUN mkdir -p /etc/cas/config /etc/cas/services /etc/cas/templates/fragments /etc/cas/templates/login /etc/cas/templates/logout /etc/cas/static/css /etc/cas/static/fonts /etc/cas/static/images /etc/cas/static/js

COPY docker/cas.properties /etc/cas/config/cas.properties
COPY docker/log4j.xml /etc/cas/config/log4j.xml
COPY docker/default.json /etc/cas/services/default-00.json

COPY ${cas_templatespath}/static/css/* /etc/cas/static/css/
COPY ${cas_templatespath}/static/fonts/* /etc/cas/static/fonts/
COPY ${cas_templatespath}/static/images/* /etc/cas/static/images/
COPY ${cas_templatespath}/static/js/* /etc/cas/static/js/
COPY ${cas_templatespath}/templates/layout.html /etc/cas/templates/layout.html
COPY ${cas_templatespath}/templates/fragments/* /etc/cas/templates/fragments/
COPY ${cas_templatespath}/templates/login/* /etc/cas/templates/login/
COPY ${cas_templatespath}/templates/logout/* /etc/cas/templates/logout/
COPY bin/ldappassword.php /tmp/

RUN mkdir /var/www/html/viticonnect
COPY viticonnect/api.php /var/www/html/viticonnect
COPY viticonnect/config.php.example /var/www/html/viticonnect/config.php

COPY docker/init.sh /tmp/init.sh
RUN bash init.sh $ldap_domain $ldap_passwd $ldap_test_username $ldap_test_password $viticonnect_shared_secret

COPY docker/ldap_bcrypt.sh /tmp/ldap_bcrypt.sh
RUN bash /tmp/ldap_bcrypt.sh

ENV CATALINA_HOME=/usr/share/tomcat9
ENV CATALINA_BASE=/var/lib/tomcat9
ENV CATALINA_TMPDIR=/tmp
ENV JAVA_OPTS=-Djava.awt.headless=true

RUN rsync -a /var/lib/ldap/ /var/lib/ldap_init

VOLUME /var/lib/ldap

EXPOSE 80
EXPOSE 389
ENTRYPOINT service slapd stop && service apache2 stop && rsync -au /var/lib/ldap_init/ /var/lib/ldap && service slapd start && service apache2 start && /usr/libexec/tomcat9/tomcat-start.sh