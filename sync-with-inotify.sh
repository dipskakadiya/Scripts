#!/bin/bash
while true
do

	# Monitor Files Changes For Create, Delete, Move, File Permissions
	inotifywait --exclude .swp ~  -r -e create -e modify -e delete -e move -e attrib --format %e:%f /var/www/

	# Detect Server:
	# Detect.txt is soft linked to /usr/local/bin/Detect.txt
	# Detect.txt Contains Uniq Live/Backup Server Identify Strings
	curl -sL DOMAIN.com/Detect.txt | grep -i LIVESERVERNAME
	

	if [ $? -eq 0 ]
	then

		# Send Details To Log Files
		echo "The LIVE-SERVER Is Running, Sending Changes From LIVE-SERVER To BACKUP-SERVER:"

		# Start Synchronisation
		#rsync -avz --delete /var/www root@BACKUP-SERVER-IP:/var/
		rsync -avz /var/www root@LIVE-SERVER-IP:/var/
	
		# If Rsync Fails
		if [ $? != 0 ]
		then

			echo "[+] Checking Server Health Script Is Already Running Or Not"
			ps ax | grep check-server-health.sh | grep -v grep

			if [ $? != 0 ]
			then
				echo "[+] Starting Check Server Health Script"
				bash /root/bin/check-server-health.sh &
			fi
		fi
		
	else
		# Send Details To Log Files
		echo "The BACKUP-SERVER Is Running, Can't Sending Changes From LIVE-SERVER To BACKUP-SERVER:"
	fi
done
