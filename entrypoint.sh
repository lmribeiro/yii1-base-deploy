#!/bin/bash

mkdir -p /root/.ssh
ssh-keyscan -H "$2" >> /root/.ssh/known_hosts

if [ -z "$DEPLOY_KEY" ];
then
	echo $'\n' "------ DEPLOY KEY NOT SET YET! ----------------" $'\n'
	exit 1
else
	printf '%b\n' "$DEPLOY_KEY" > /root/.ssh/id_rsa
	chmod 400 /root/.ssh/id_rsa

	echo $'\n' "------ CONFIG SUCCESSFUL! ---------------------" $'\n'
fi

rsync --progress -avzh \
	--exclude='.git/' \
	--exclude='.git*' \
	--exclude='.idea/' \
	--exclude='readme.md' \
	--exclude='README.md' \
	-e "ssh -i /root/.ssh/id_rsa" \
	--rsync-path="sudo rsync" . $1@$2:$3

if [ $? -eq 0 ]
then
	echo $'\n' "------ SYNC SUCCESSFUL! -----------------------" $'\n'
	echo $'\n' "------ RELOADING PERMISSION -------------------" $'\n'

	ssh -i /root/.ssh/id_rsa -tt $1@$2 "sudo chown -R $4:$4 $3"
	ssh -i /root/.ssh/id_rsa -tt $1@$2 "sudo chmod 775 -R $3/protected/runtime"
	ssh -i /root/.ssh/id_rsa -tt $1@$2 "sudo chmod 777 -R $3/public_html/assets"
	
	echo $'\n' "------ RUN MIGRATIONS -------------------------" $'\n'
	
	ssh -i /root/.ssh/id_rsa -tt $1@$2 "php $3/protected/yiic migrate up --interactive=0"

	echo $'\n' "------ CONGRATS! DEPLOY SUCCESSFUL!!! ---------" $'\n'
	exit 0
else
	echo $'\n' "------ DEPLOY FAILED! -------------------------" $'\n'
	exit 1
fi
