#!/bin/sh

### Selective routing ###
# Route only specific domains to Tor network.
# Selectively utilize DNS over Tor.
# Beware of privacy issues as each site may use multiple domains.

# Process traffic by destination
for IPV in 4 6
do case ${IPV} in
(4) TOR_DST="172.16.0.0/12" ;;
(6) TOR_DST="fc00::/8" ;;
esac
uci -q delete firewall.tcp_int${IPV%4}
uci set firewall.tcp_int${IPV%4}="redirect"
uci set firewall.tcp_int${IPV%4}.name="Intercept-TCP"
uci set firewall.tcp_int${IPV%4}.src="lan"
uci set firewall.tcp_int${IPV%4}.src_dip="${TOR_DST}"
uci set firewall.tcp_int${IPV%4}.src_dport="0-65535"
uci set firewall.tcp_int${IPV%4}.dest_port="9040"
uci set firewall.tcp_int${IPV%4}.proto="tcp"
uci set firewall.tcp_int${IPV%4}.target="DNAT"
uci -q delete firewall.lan_wan${IPV%4}
uci set firewall.lan_wan${IPV%4}="rule"
uci set firewall.lan_wan${IPV%4}.name="Allow-NonTor-Forward"
uci set firewall.lan_wan${IPV%4}.src="lan"
uci set firewall.lan_wan${IPV%4}.dest="wan"
uci set firewall.lan_wan${IPV%4}.dest_ip="!${TOR_DST}"
uci set firewall.lan_wan${IPV%4}.proto="all"
uci set firewall.lan_wan${IPV%4}.target="ACCEPT"
done
uci -q delete firewall.tor_nft
uci commit firewall
service firewall restart
 
# Configure Tor domains
uci -q delete dhcp.@dnsmasq[0].noresolv
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="/onion/127.0.0.1#9053"
uci add_list dhcp.@dnsmasq[0].server="/example.com/127.0.0.1#9053"
uci add_list dhcp.@dnsmasq[0].server="/example.net/127.0.0.1#9053"
uci commit dhcp
service dnsmasq restart


