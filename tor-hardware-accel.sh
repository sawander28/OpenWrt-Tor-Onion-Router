#!/bin/sh

# Enable Tor hardware acceleration
cat << EOF >> /etc/tor/custom
HardwareAccel 1
EOF
service tor restart
