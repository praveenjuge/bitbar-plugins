#!/bin/bash
# <bitbar.title>Got Internet?</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Federico Brigante</bitbar.author>
# <bitbar.author.github>bfred-it</bitbar.author.github>
# <bitbar.desc>Checks the connection to Internet and tells you in a single character.</bitbar.desc>
# <bitbar.image>http://i.imgur.com/I8lF8st.png</bitbar.image>

ping_timeout=1 #integers only, ping's fault
ping_address=8.8.8.8
EXTERNAL_IP4=$(curl -4 --connect-timeout 3 -s http://v4.ipv6-test.com/api/myip.php || echo None)
[[ "$EXTERNAL_IP4" == "None" ]] && WHOIS="" || WHOIS=$(whois "$EXTERNAL_IP4" | awk '/descr: / {$1=""; $0=substr($0,1,length($0)-1); print $0 }' | head -n 1)
INTERFACES=$(ifconfig | grep UP | egrep -o '(^en[0-9]*|^utun[0-9]*)' | sort -n)

notify () {
    osascript -e "display notification \"$1\" with title \"Got it 👍\""
}

# If called with parameter "copy", copy the second parameter to the clipboard
if [ "$1" = "copy" ]; then
  echo "$2" | pbcopy
  notify "Copied $2 to clipboard"
  exit 0
fi


if ! ping -c 1 -t $ping_timeout -q $ping_address > /dev/null 2>&1; then
	echo "😡|color=#FFFFFF dropdown=false"
	echo "---"
	echo "You're offline | color=red"
	# echo "Ping to Google DNS failed"
else
	echo "😁|dropdown=false"
	echo "---"
	echo "You're online | color=green"
	echo "---"
	echo "${EXTERNAL_IP4}${WHOIS} | terminal=false bash='$0' param1=copy param2=$EXTERNAL_IP4"
	for INT in $INTERFACES; do
	     ifconfig "$INT" | awk "/inet / { print \"Local IP: \" \$2 \" | terminal=false bash='$0' param1=copy param2=\" \$2 }" | sed -e 's/%utun[0-9]*//g' -e 's/%en[0-9]*//g' | sort
	done
	echo "---"
fi
