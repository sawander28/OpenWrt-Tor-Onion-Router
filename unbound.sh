#!/bin/sh

# Install packages
opkg update
opkg install unbound-daemon luci-app-unbound
# Restart luci
service rpcd restart

# Install & setup unbound dns-server
opkg install unbound-anchor unbound-checkconf unbound-host 
opkg install unbound-control unbound-control-setup
uci set unbound.fwd_google.enabled="0"
uci set unbound.fwd_cloudflare.enabled="1"
uci set unbound.fwd_cloudflare.fallback="0"
uci commit unbound
service unbound restart

# Enforce DNSSEC validation
uci set unbound.@unbound[0].validator="1"
uci commit unbound
service unbound restart
