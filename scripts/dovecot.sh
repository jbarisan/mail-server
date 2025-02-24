#!/bin/bash

# 10-ssl.conf
sed -i '/^ssl_dh =/s/^/#/' /etc/dovecot/conf.d/10-ssl.conf
sed -i '/^ssl_cert =/c\ssl_cert = </etc/letsencrypt/live/mail.barisano.dev/fullchain.pem' /etc/dovecot/conf.d/10-ssl.conf
sed -i '/^ssl_key =/c\ssl_key = </etc/letsencrypt/live/mail.barisano.dev/privkey.pem' /etc/dovecot/conf.d/10-ssl.conf

# 10-auth.conf
sed -i 's/auth_mechanisms = plain/auth_mechanisms = plain login/' /etc/dovecot/conf.d/10-master.conf
sed -i 's/#disable_plaintext_auth = yes/disable_plaintext_auth = yes/' /etc/dovecot/conf.d/10-auth.conf

# 10-master.conf
sed -i '0,/#ssl/s/#ssl/ssl/' /etc/dovecot/conf.d/10-master.conf # replace first occurance only which is for imaps
sed -i 's/#port = 993/port = 993/' /etc/dovecot/conf.d/10-master.conf
sed -i 's/#port = 587/port = 587/' /etc/dovecot/conf.d/10-master.conf
sed -i '82,/#process_limit = 1024/s/#process_limit = 1024/process_limit = 1024/' /etc/dovecot/conf.d/10-master.conf # replace 3rd occurance which is for submission (line 83)
sed -i '107,/#unix_listener \/var\/spool\/postfix\/private\/auth/s/#unix_listener \/var\/spool\/postfix\/private\/auth/unix_listener \/var\/spool\/postfix\/private\/auth/' /etc/dovecot/conf.d/10-master.conf
sed -i '107,/#  mode = 0666/s/#  mode = 0666/  mode = 0666/' /etc/dovecot/conf.d/10-master.conf
sed -i '107,/#}/s/#}/}/' /etc/dovecot/conf.d/10-master.conf
sed -i '108a\\    group = postfix' /etc/dovecot/conf.d/10-master.conf
sed -i '108a\\    user = postfix' /etc/dovecot/conf.d/10-master.conf

dovecot reload
