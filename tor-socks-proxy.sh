#!/bin/sh
# tor-socks-proxy
# Enable Tor socks proxy
cat << EOF >> /etc/tor/custom
SOCKSPort 0.0.0.0:9050
SOCKSPort [::]:9050
EOF
service tor restart
