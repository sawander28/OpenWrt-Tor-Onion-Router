#!/bin/sh

### Client authorization ###
# Secure access to onion services with client authorization
# Install packages
opkg update
opkg install openssl-util coreutils-base32
 
# Enable client authorization
openssl genpkey -algorithm x25519 -out /etc/tor/hidden_service.pem
TOR_KEY="$(openssl pkey -in /etc/tor/hidden_service.pem -outform der \
| tail -c 32 \
| base32 \
| sed -e "s/=//g")"
TOR_PUB="$(openssl pkey -in /etc/tor/hidden_service.pem -outform der -pubout \
| tail -c 32 \
| base32 \
| sed -e "s/=//g")"
TOR_HOST="$(cat /etc/tor/hidden_service/ssh/hostname)"
cat << EOF > client.auth_private
${TOR_HOST%.onion}:descriptor:x25519:${TOR_KEY}
EOF
cat << EOF > /etc/tor/hidden_service/ssh/authorized_clients/client.auth
descriptor:x25519:${TOR_PUB}
EOF
chown -R tor:tor /etc/tor/hidden_service/
service tor restart


# Configure authorization on the client using the private key.
# Configure client authorization
cat << EOF >> /etc/tor/custom
ClientOnionAuthDir /etc/tor/onion_auth
EOF
umask go=
TOR_AUTH="$(cat client.auth_private)"
TOR_HOST="${TOR_AUTH%%:*}.onion"
mkdir -p /etc/tor/onion_auth
cat << EOF > /etc/tor/onion_auth/client.auth_private
${TOR_AUTH}
EOF
chown -R tor:tor /etc/tor/onion_auth
service tor restart
