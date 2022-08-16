#!/bin/bash

. $(dirname $0)/config.inc

login=$1
raison_sociale=$2
siret=$3
cvi=$4
accises=$5
tva=$6
ppm=$7

read password

if ! test "$login" || ! test "$siret" || ! test "$raison_sociale" || ! test "$password"; then
    echo "$0: <login> <raison_sociale> <siret> [<cvi> [<accises> [<tva> [<ppm]]]]" >&2 ;
    echo "    login ($login) raison_sociale ($raison_sociale) siret ($siret) mandatory" >&2 ; 
    echo "    password ($password) must be passed by stdin" >&2 ;
    exit 2
fi

sshapasswd=$(echo $password | php $(dirname $0)/ldappassword.php)

cat > /tmp/createldapuser.$$.ldif <<EOF

dn: uid=$login,ou=People,$ldap_bind
uid: $login
cn: Compte de test
objectClass: top
objectClass: person
objectClass: posixAccount
objectClass: inetOrgPerson
loginShell: /bin/bash
$ldap_raison_sociale: $raison_sociale
userPassword: $sshapasswd
$ldap_siret: $siret
uidNumber: $siret
gidNumber: $siret
homeDirectory: /home/$siret
EOF

if test "$tva"; then
echo "$ldap_tva: $tva" >> /tmp/createldapuser.$$.ldif
fi
if test "$cvi"; then
echo "$ldap_cvi: $cvi" >> /tmp/createldapuser.$$.ldif
fi
if test "$accises"; then
echo "$ldap_accises: $accises" >> /tmp/createldapuser.$$.ldif
fi
if test "$ppm"; then
echo "$ldap_ppm: $ppm" >> /tmp/createldapuser.$$.ldif
fi

ldapadd -H ldap://localhost:389 -c -x -D cn=admin,$ldap_bind -w $ldap_passwd < /tmp/createldapuser.$$.ldif

rm /tmp/createldapuser.$$.ldif