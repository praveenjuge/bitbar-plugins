#!/bin/bash
# <bitbar.title>Got Internet?</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Federico Brigante</bitbar.author>
# <bitbar.author.github>bfred-it</bitbar.author.github>
# <bitbar.desc>Checks the connection to Internet and tells you in a single character.</bitbar.desc>
# <bitbar.image>http://i.imgur.com/I8lF8st.png</bitbar.image>

ping_timeout=1
ping_address=8.8.8.8

EXTERNAL_IP4=$(curl -4 --connect-timeout 3 -s http://v4.ipv6-test.com/api/myip.php || echo None)
[[ "$EXTERNAL_IP4" == "None" ]] && WHOIS="" || WHOIS=$(whois "$EXTERNAL_IP4" | awk '/descr: / {$1=""; $0=substr($0,1,length($0)-1); print $0 }' | head -n 1)
LIP=$(ifconfig | awk "/inet / { print \$2 \" | terminal=false bash='$0' param1=copy param2=\" \$2 }" | sed -n '2p')

notify () {
    osascript -e "display notification \"$1\" with title \"Got it 👍\""
}

if [ "$1" = "copy" ]; then
  echo "$2" | pbcopy
  notify "Copied $2 to clipboard"
  exit 0
fi

if ! ping -c 1 -t $ping_timeout -q $ping_address > /dev/null 2>&1; then
	echo "😡|dropdown=false"
	echo "---"
	echo "You're offline | color=red"
else
	echo "😁|dropdown=false"
	echo "---"
	echo "You're online | color=green"
	echo "---"
	echo "${EXTERNAL_IP4}${WHOIS} | terminal=false bash='$0' param1=copy param2=$EXTERNAL_IP4"
	echo "Local IP: $LIP"
fi
