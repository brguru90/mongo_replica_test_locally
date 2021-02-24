#!/bin/bash

if ! whoami | grep -q "root" -i; then
    echo "Plaese run it as root user"
    exit
fi

full_path=$(realpath $0)
cur_dir=$(dirname $full_path)

port="27019"
CUR_HOST="127.0.0.1"
CUR_DIR="$cur_dir/mongodb/"

if [ -n "$1" ]
then
    port=$1
fi

if [ -n "$2" ]
then
    CUR_HOST=$2
fi

if [ -n "$3" ]
then
    CUR_DIR=$3
fi



basedir="$CUR_DIR/port_$port"
pathPrefix="$basedir/tmp"
pidFilePath="$pathPrefix/mongodb.pid"
keyFile="$basedir/key.txt"
dbPath="$basedir/data/db"
logPath="$basedir/logs"

mkdir -p "./mongodb/$basedir"


# running=$(lsof -i :$port | wc -l)
# if [ $running -eq 0 ]
# then
#     echo "resetting $port"
#     fuser -k $port/tcp
#     rm -rf "./mongodb/$basedir"
# else
#     echo "$port already running"
#     echo -e "use admin;\nrs.add({ host:'localhost:$port', priority: 0, votes: 0 });\nexit\n" > "$basedir/add_replicaset.js"
#     echo "replicasetkeyCisco123" > key.txt
#     mongo -u __system -p "$(tr -d '\011-\015\040' < key.txt)" --authenticationDatabase local < "$basedir/add_replicaset.js"
#     exit 0
# fi


mkdir -p $dbPath
mkdir -p $pathPrefix
mkdir -p $logPath
touch "$logPath/mongodb.log"

echo "replicasetkeyCisco123" > $keyFile

chmod 600  $basedir
chown mongodb:mongodb  $basedir

chmod 600 -R $basedir
chown mongodb:mongodb -R $basedir ./mongod.conf
# chmod 600  $basedir/key.txt
# chown root:root ./mongod.conf
chmod 644 ./mongod.conf
ls -lR $basedir
ls -l


cp ./mongod.conf $cur_dir/mongod.conf -f

fuser -k $port/tcp

cmd1="mongod --config $cur_dir/mongod.conf \\
    --port $port \\
    --unixSocketPrefix $pathPrefix \\
    --pidfilepath $pidFilePath \\
    --keyFile $keyFile \\
    --dbpath $dbPath \\
    --logpath '$logPath/mongodb.log'"


echo -e "use admin;\nrs.add({ host:'localhost:$port', priority: 0, votes: 0 });\nexit\n" > "$basedir/add_replicaset.js"
cmd2="mongo -u __system -p \"$(tr -d '\011-\015\040' < $keyFile)\" --authenticationDatabase local <  \"$basedir/add_replicaset.js\" "


service_config_1="
[Unit]
Description=mongo_replica_on_port_$port
After=multi-user.target
Conflicts=getty@tty1.service

[Service]
Type=simple
Restart=always
RestartSec=10
User=root
ExecStart=$cmd1
StandardInput=tty-force

[Install]
WantedBy=multi-user.target
"


service_config_2="
[Unit]
Description=mongo_replica_add_port_$port
After=multi-user.target
Conflicts=getty@tty1.service

[Service]
Type=simple
Restart=always
RestartSec=60
User=root
ExecStart=$cmd2
StandardInput=tty-force

[Install]
WantedBy=multi-user.target
"

echo  "$service_config_1"

echo  "$service_config_2" 


service_file1="mongo_replica_on_port_$port.service"
echo "$service_config_1" > /lib/systemd/system/$service_file1
echo "$service_config_1" > /etc/systemd/system/$service_file1
systemctl daemon-reload
systemctl stop $service_file1
systemctl enable $service_file1
systemctl start $service_file1


 
service_file2="mongo_replica_add_port_$port.service"
echo "$service_config_2" > /lib/systemd/system/$service_file2
echo "$service_config_2" > /etc/systemd/system/$service_file2
systemctl daemon-reload
systemctl stop $service_file2
systemctl enable $service_file2
systemctl start $service_file2

sleep 1

systemctl status $service_file1 &
systemctl status $service_file2 &