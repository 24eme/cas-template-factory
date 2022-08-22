apt install -y -q vim make curl libtool libdb5.3-dev groff-base
curl http://deb.debian.org/debian/pool/main/o/openldap/openldap_2.4.57+dfsg.orig.tar.gz | tar zxvf -
cd openldap-2.4.57+dfsg/
./configure && make depend && make
cd contrib/slapd-modules/passwd/
git clone https://github.com/wclarie/openldap-bcrypt.git
#git clone https://github.com/dnwright/openldap-bcrypt.git
cd openldap-bcrypt
sed -i 's|LDAP_LIB = |LDAP_LIB = -L/tmp/openldap-2.4.57+dfsg/libraries/libldap_r/.libs/ |' Makefile
sed -i 's|moduledir = .*|moduledir = \/usr\/lib\/ldap|' Makefile 
make
make install
pkill slapd
service slapd start
ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: pw-bcrypt
EOF

cd
rm -rf /tmp/openldap-2.4.57+dfsg /tmp/ldap_bcrypt.sh