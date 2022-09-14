#!/bin/bash
#enviarloginterface.sh
SCRIPT=$(readlink -f $0)
DIRBASE=$(dirname $SCRIPT)
cd $DIRBASE

BOT="$(cat $DIRBASE/BOT)"
CHAT="$(cat $DIRBASE/CHAT)"

curl -s -X POST https://api.telegram.org/bot"$BOT"/sendDocument -F chat_id="$CHAT" -F caption="Log Telegram Bot Interface" -F document="@/var/log/interface.log" >>/var/log/telegram.log 2>>/var/log/telegram.log
