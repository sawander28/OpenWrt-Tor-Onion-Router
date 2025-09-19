# https://openwrt.org/docs/guide-user/services/tor/client

# Install packages
opkg update
opkg install tor torsocks tor-geoip obfs4proxy

# Configure Tor client
cat << EOF > /etc/tor/custom
AutomapHostsOnResolve 1
AutomapHostsSuffixes .
VirtualAddrNetworkIPv4 172.16.0.0/12
VirtualAddrNetworkIPv6 [fc00::]/7
DNSPort 0.0.0.0:9053
DNSPort [::]:9053
TransPort 0.0.0.0:9040
TransPort [::]:9040
EOF
cat << EOF >> /etc/sysupgrade.conf
/etc/tor/*
EOF
uci del_list tor.conf.tail_include="/etc/tor/custom"
uci add_list tor.conf.tail_include="/etc/tor/custom"
uci commit tor
service tor restart

# Intercept DNS traffic
uci -q del firewall.dns_int
uci set firewall.dns_int="redirect"
uci set firewall.dns_int.name="Intercept-DNS"
uci set firewall.dns_int.family="any"
uci set firewall.dns_int.proto="tcp udp"
uci set firewall.dns_int.src="lan"
uci set firewall.dns_int.src_dport="53"
uci set firewall.dns_int.dest_port="53"
uci set firewall.dns_int.target="DNAT"
uci commit firewall
service firewall restart

# Enable DNS over Tor
service dnsmasq stop
uci set dhcp.@dnsmasq[0].localuse="0"
uci set dhcp.@dnsmasq[0].noresolv="1"
uci set dhcp.@dnsmasq[0].rebind_protection="0"
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="127.0.0.1#9053"
uci add_list dhcp.@dnsmasq[0].server="::1#9053"
uci commit dhcp
service dnsmasq start

# Intercept TCP traffic
cat << "EOF" > /etc/nftables.d/tor.sh
TOR_CHAIN="dstnat_$(uci -q get firewall.tcp_int.src)"
TOR_RULE="$(nft -a list chain inet fw4 ${TOR_CHAIN} \
| sed -n -e "/Intercept-TCP/p")"
nft replace rule inet fw4 ${TOR_CHAIN} \
handle ${TOR_RULE##* } \
fib daddr type != { local, broadcast } ${TOR_RULE}
EOF
uci -q delete firewall.tor_nft
uci set firewall.tor_nft="include"
uci set firewall.tor_nft.path="/etc/nftables.d/tor.sh"
uci -q delete firewall.tcp_int
uci set firewall.tcp_int="redirect"
uci set firewall.tcp_int.name="Intercept-TCP"
uci set firewall.tcp_int.src="lan"
uci set firewall.tcp_int.src_dport="0-65535"
uci set firewall.tcp_int.dest_port="9040"
uci set firewall.tcp_int.proto="tcp"
uci set firewall.tcp_int.family="any"
uci set firewall.tcp_int.target="DNAT"

# Disable LAN to WAN forwarding
uci -q delete firewall.@forwarding[0]
uci commit firewall
service firewall restart
