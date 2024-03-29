#!/bin/bash

ldap_domain=$1
ldap_passwd=$2
ldap_test_user=$3
ldap_test_pass=$4
viticonnect_secret=$5

echo "Cloning Apereo/CAS"
echo "===================="

git clone https://github.com/apereo/cas-overlay-template.git
cd cas-overlay-template
git checkout 6.5

echo "Prepare compilation"
echo "===================="

echo "dependencies {" >> build.gradle
echo 'implementation "org.apereo.cas:cas-server-support-ldap:${project.'"'"'cas.version'"'"'}"' >> build.gradle
echo 'implementation "org.apereo.cas:cas-server-support-json-service-registry:${project.'"'"'cas.version'"'"'}"' >> build.gradle
echo 'implementation "org.apereo.cas:cas-server-support-generic:${project.'"'"'cas.version'"'"'}"' >> build.gradle
echo "}" >> build.gradle
sed -i 's/sourceCompatibility=[0-9]*/sourceCompatibility=11/' gradle.properties
sed -i 's/targetCompatibility=[0-9]*/targetCompatibility=11/' gradle.properties

echo "Compile Apaero/CAS"
echo "===================="

./gradlew clean build

echo "Deploy WAR on tomcat"
echo "===================="

cp build/libs/cas.war /var/lib/tomcat*/webapps/

echo "Adapt configuration"
echo "===================="

ldap_bind=$(echo $ldap_domain | sed 's/^/dc=/' | sed 's/\./,dc=/');
sed -i 's/dc=example,dc=org/'$ldap_bind'/' /etc/cas/config/cas.properties
sed -i 's/bindCredential=.*/bindCredential='$ldap_passwd'/' /etc/cas/config/cas.properties
sed -i 's/example.org/'$ldap_domain'/' /etc/cas/config/cas.properties

echo "LDAP creation"
echo "===================="
service slapd restart

cat <<EOF > init.ldif
dn: ou=People,$ldap_bind
objectClass: top
objectClass: organizationalUnit
ou: People

EOF

if test "$ldap_test_user" && test "$ldap_test_pass" ; then

ldap_test_ssha=$(echo $ldap_test_pass | php /tmp/ldappassword.php)

cat <<EOF >> init.ldif

dn: uid=$ldap_test_user,ou=People,$ldap_bind
uid: $ldap_test_user
cn: Compte de test
objectClass: top
objectClass: person
objectClass: posixAccount
objectClass: inetOrgPerson
loginShell: /bin/bash
uidNumber: 1
gidNumber: 1000
homeDirectory: /home/000001
sn: Raison sociale
o: TVA
description: CVI
street: ACCISES
telephoneNumber: SIRET
facsimileTelephoneNumber: PPM
userPassword: $ldap_test_ssha
EOF
fi

echo " =============================================================================="
echo "| Le mot de passe du compte de test '$ldap_test_user' est '$ldap_test_pass' (sans ') |"
echo " =============================================================================="
echo " SUPPRIMEZ LE COMPTE $ldap_test_username UNE FOIS EN PRODUCTION !"

ldapadd -H ldap://localhost:389 -c -x -D cn=admin,$ldap_bind -w $ldap_passwd < init.ldif

echo "viticonnect"
echo "===================="

sed -i 's/SHARED_SECRET/'$viticonnect_secret'/' /var/www/html/viticonnect/config.php
sed -i 's/dc=example,dc=org/'$ldap_bind'/' /var/www/html/viticonnect/config.php
echo > /var/www/html/viticonnect/index.html

echo "Cleaning"
echo "===================="

cd /
rm -rf /tmp/cas-overlay-template /tmp/init.sh /tmp/ldappassword.php