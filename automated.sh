#!/bin/sh

URL="https://openwrt.org/_export/code/docs/guide-user/services/tor/client"
cat << EOF > tor-client.sh
$(wget -U "" -O - "${URL}?codeblock=0")
$(wget -U "" -O - "${URL}?codeblock=1")
$(wget -U "" -O - "${URL}?codeblock=2")
$(wget -U "" -O - "${URL}?codeblock=3")
EOF
sh tor-client.sh
