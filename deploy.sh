#!/bin/bash

export PORT=5300
export MIX_ENV=prod
export GIT_PATH=/home/tanks/src/tanks

PWD=`pwd`
if [ $PWD != $GIT_PATH ]; then
	echo "Error: Must check out git repo to $GIT_PATH"
	echo "  Current directory is $PWD"
	exit 1
fi

if [ $USER != "tanks" ]; then
	echo "Error: must run as user 'tanks'"
	echo "  Current user is $USER"
	exit 2
fi

mix deps.get
(cd assets && npm install)
(cd assets && ./node_modules/brunch/bin/brunch b -p)
mix phx.digest
mix ecto.create
mix ecto.migrate

mix release --env=prod

mkdir -p ~/www
mkdir -p ~/old

NOW=`date +%s`
if [ -d ~/www/tanks ]; then
	echo mv ~/www/tanks ~/old/$NOW
	mv ~/www/tanks ~/old/$NOW
fi

mkdir -p ~/www/tanks
REL_TAR=~/src/tanks/_build/prod/rel/tanks/releases/0.0.1/tanks.tar.gz
(cd ~/www/tanks && tar xzvf $REL_TAR)

crontab - <<CRONTAB
@reboot bash /home/tanks/src/tanks/start.sh
CRONTAB

#. start.sh
