#!/bin/bash

smtp_url=$1
smtp_port=$2
user=$3
pass=$4
cert="/etc/letsencrypt/live/$(hostname -f)/fullchain.pem"
private_key="/etc/letsencrypt/live/$(hostname -f)/privkey.pem"

# set from domain instead of using full fqdn
echo 'barisano.dev' > /etc/mailname

# main.cf - Update existing lines
postconf -e "smtpd_tls_cert_file=$cert"
postconf -e "smtpd_tls_key_file=$private_key"
postconf -e "myhostname = $(hostname -d)"
postconf -e "mydestination = $(hostname -d), $(postconf mydestination | cut -d= -f2)"
postconf -e "relayhost = [$smtp_url]:$smtp_port"

# main.cf - Add new lines
postconf -e "smtpd_sasl_type = dovecot"
postconf -e "smtpd_sasl_auth_enable = yes"
postconf -e "smtpd_sasl_path = private/auth"
postconf -e "smtp_sasl_auth_enable = yes"
postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
postconf -e "smtp_sasl_security_options = noanonymous"
postconf -e "smtp_sasl_tls_security_options = noanonymous"
postconf -e "header_size_limit = 4096000"

# master.cf - Enable submission service for relaying outgoing email
# remove the # if the lines are commented out
sudo sed -i '17s/^#//g' /etc/postfix/master.cf
sudo sed -i '18s/^#//g' /etc/postfix/master.cf
sudo sed -i '19s/^#//g' /etc/postfix/master.cf
sudo sed -i '20s/^#//g' /etc/postfix/master.cf

# sasl
echo [$smtp_url]:$smtp_port $user:$pass >> /etc/postfix/sasl_passwd
chmod 600 /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd
rm /etc/postfix/sasl_passwd

# write changes
postfix reload