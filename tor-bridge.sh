#!/bin/sh

### Exit nodes ###
# Exclude dubious exit nodes by their country codes.

### Pluggable transports ###

# Circumvent ISP restrictions with bridges

# Install packages
opkg update
opkg install obfs4proxy
 
# Configure bridges
cat << EOF >> /etc/tor/custom
UseBridges 1
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy
Bridge obfs4 154.35.22.10:443 8FB9F4319E89E5C6223052AA525A192AFBC85D55 \
cert=GGGS1TX4R81m3r0HBl79wKy1OtPPNR2CZUIrHjkRg65Vc2VR8fOyo64f9kmT1UAFG7j0HQ iat-mode=0
Bridge obfs4 154.35.22.12:80 00DC6C4FA49A65BD1472993CF6730D54F11E0DBB \
cert=N86E9hKXXXVz6G7w2z8wFfhIDztDAzZ/3poxVePHEYjbKDWzjkRDccFMAnhK75fc65pYSg iat-mode=0
EOF
service tor restart
