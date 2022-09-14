# simplytelegrambot
Simply Telegram Bot for Raspberry Pi 4.
Developep 100% Bash and Debian 11.

#Add this line in the root crontab:
@reboot /root/telegram/interface.sh > /var/log/interface.log 2>&1 &