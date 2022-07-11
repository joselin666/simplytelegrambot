#!/bin/bash
#interface.sh

# Raspberry Simply Telegram Interface
VERSION="1.0\nBot de Telegram para Raspberry by joselin666"

# Enter your token
TOKEN="$(cat /root/telegram/BOT)"

# Enter your channel id
CHANNEL="$(cat /root/telegram/CHAT)"

# File where the number of the last processed message will be saved
LASTMSG=/root/telegram/lastmsg

# Commands
# use this format: ["/ mi command"] = '<comando del sistema>'
# Please remember to remove unnecessary examples
# You can add these commands to the list of telegram commands with the function "/setcommands in BotFather"

echo -e "\nRaspberry Simply Telegram Interface v${VERSION}\n"
ABOUTME=`curl -s "https://api.telegram.org/bot${TOKEN}/getMe"`
if [[ "$ABOUTME" =~ \"ok\"\:true\, ]]; then
	if [[ "$ABOUTME" =~ \"username\"\:\"([^\"]+)\" ]]; then
		echo -e "Bot Nick:\t @${BASH_REMATCH[1]}"
	fi

	if [[ "$ABOUTME" =~ \"first_name\"\:\"([^\"]+)\" ]]; then
		echo -e "Bot Name:\t ${BASH_REMATCH[1]}"
	fi

	if [[ "$ABOUTME" =~ \"id\"\:([0-9\-]+), ]]; then
		echo -e "Bot ID:\t\t ${BASH_REMATCH[1]}"
	fi

else
	echo "Error: The bot for that token was not found."
	exit;
fi

if [ -e "$LASTMSG" ]
then
	echo "Last Message Processed:"
	cat $LASTMSG
else
	echo "0" > $LASTMSG
fi

date
echo -e "\nService Started... Waiting for new messages\n"
/root/telegram/notificararranque.sh

while true; do
	MSGOUTPUT=$(curl -s "https://api.telegram.org/bot${TOKEN}/getUpdates")
	MSGID=0
	TEXT=0

	echo -e "${MSGOUTPUT}" | while read -r line
	do
		if [[ "$line" =~ \"chat\"\:\{\"id\"\:([\-0-9]+)\, ]]
		then
			CHATID=${BASH_REMATCH[1]}
		fi

		if [[ "$line" =~ \"message\_id\"\:([0-9]+)\, ]]
		then
			MSGID=${BASH_REMATCH[1]}
		fi

	 	if [[ "$line" =~ \"date\"\:([0-9]+)\, ]]
		then
			DATE=${BASH_REMATCH[1]}
		fi

		if [[ "$line" =~ \"text\"\:\"([^\"]+)\" ]]
		then
			TEXT=${BASH_REMATCH[1]}
		fi

# I read the last processed msg
		LASTMSGID=$(cat "$LASTMSG")
		ESROBOT=${TEXT:0:1}
# I calculate the age of the message, if it comes without a date they are headers and I reject them
		DATENOW=$(date "+%s")
		if [[ "$DATE" == "" ]]
		then
			ANTIGUEDAD=99
		else
			ANTIGUEDAD=$(expr $DATENOW - $DATE)
		fi
# I process the lines that have a message and are new, have a chat number and coincide with the one I am processing and the line begins with a command and is less than 15 seconds old
		if [[ $MSGID -ne 0 && $CHATID -ne 0 && $CHATID = $CHANNEL && $MSGID -gt $LASTMSGID && "$ESROBOT" == "/" && $ANTIGUEDAD -lt 15 ]]
		then
			robot=$(echo $TEXT| cut -d' ' -f 1)
#If the user types an unknown command I pull up the menu with the Valid options
			CMD="echo -e Welcome to Raspberry Bot\n/uptime \n/disk \n/ping <IP to Check>\n/run <Command to execute>\n/reboot \n/apagar \n\n/red \n/router \n/mibox \n/rec \n\n/log \n/menu"

#/ping
			if [[ "$robot" == "/ping" ]]
			then
				CMD="ping -c3 ${TEXT:6}"
			fi
#/uptime
			if [[ "$robot" == "/uptime" ]]
			then
				CMD="uptime"
			fi
#/disk
			if [[ "$robot" == "/disk" ]]
			then
				CMD="df -h"
			fi
#/run 
			if [[ "$robot" == "/run" ]]
			then
				CMD="${TEXT:5}"
			fi
#/reboot
			if [[ "$robot" == "/reboot" ]]
			then
				CMD="sudo reboot"
			fi
#/apagar
			if [[ "$robot" == "/apagar" ]]
			then
				CMD="sudo shutdown -H now"
			fi
#/red
			if [[ "$robot" == "/red" ]]
			then
				CMD="ip a"
			fi
#/router
			if [[ "$robot" == "/router" ]]
			then
				CMD="ping 192.168.1.1 -c3"
			fi
#/mibox
			if [[ "$robot" == "/mibox" ]]
			then
				CMD="ping 192.168.1.10 -c3"
			fi
#/rec
			if [[ "$robot" == "/rec" ]]
			then
				CMD="/root/.NPVR-data/scripts/grabaciones.sh"
			fi
#/log
			if [[ "$robot" == "/log" ]]
			then
				CMD="/root/telegram/enviarloginterface.sh"
			fi

#EXECUTION, NOTIFICATION and UPDATE OF LAST PROCESSED MESSAGE
			RESULTADO=`$CMD`
			curl -s -d "text=${RESULTADO}&chat_id=${CHATID}" "https://api.telegram.org/bot${TOKEN}/sendMessage" > /dev/null
			echo $MSGID > "$LASTMSG"
#Log									
			echo " "
			date
			echo "Comando: $CMD"
			echo "Result:"
			echo "$RESULTADO"
		fi
	done
#segundos de espera para la proxima ejecucion
	sleep 5
done

exit 0
