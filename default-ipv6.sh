#!/bin/sh
# 
# https://openwrt.org/docs/guide-user/network/ipv6/ipv6_extras#disabling_gua_prefix
#
# Disabling GUA prefix
uci set network.lan.ip6class="local"
uci commit network
service network restart

# Announcing IPv6 default route
uci set dhcp.lan.ra_default="1"
uci commit dhcp
service odhcpd restart

# Using IPv6 by default
NET_ULA="$(uci get network.globals.ula_prefix)"
uci set network.globals.ula_prefix="d${NET_ULA:1}"
uci commit network
service network restart

# Missing GUA prefix
#uci set dhcp.odhcpd.loglevel="3"
#uci commit dhcp
#service odhcpd restart

# Disabling IPv6 source filter
#uci set network.wan6.sourcefilter="0"
#uci commit network
#service network restart
