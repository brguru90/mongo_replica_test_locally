#!/bin/bash

port="27019"
if [ -n "$1" ]
then
    port=$1
fi


basedir="port_$port"
pathPrefix="./mongodb/$basedir/tmp"
pidFilePath="$pathPrefix/mongodb.pid"
keyFile="./mongodb/$basedir/key.txt"
dbPath="./mongodb/$basedir/data/db"
logPath="./mongodb/$basedir/logs"

mkdir -p "./mongodb/$basedir"


running=$(lsof -i :$port | wc -l)
if [ $running -eq 0 ]
then
    echo "resetting $port"
    fuser -k $port/tcp
    rm -rf "/mongodb/$basedir"
else
    echo "$port already running"
    echo -e "use admin;\nrs.add({ host:'localhost:$port', priority: 0, votes: 0 });\nexit\n" > "./mongodb/$basedir/add_replicaset.js"
    echo "replicasetkeyCisco123" > key.txt
    mongo -u __system -p "$(tr -d '\011-\015\040' < key.txt)" --authenticationDatabase local < "./mongodb/$basedir/add_replicaset.js"
    exit 0
fi


mkdir -p $dbPath
mkdir -p $pathPrefix
mkdir -p $logPath
touch "$logPath/mongodb.log"

echo "replicasetkeyCisco123" > $keyFile

chmod 600  ./mongodb
chown mongodb:mongodb  ./mongodb

chmod 600 -R ./mongodb/$basedir 
chown mongodb:mongodb -R ./mongodb/$basedir  ./mongod.conf
# chmod 600  ./mongodb/$basedir/key.txt
# chown root:root ./mongod.conf
chmod 644 ./mongod.conf
ls -lR ./mongodb/$basedir
ls -l




echo -e "use admin;\nrs.add({ host:'localhost:$port', priority: 0, votes: 0 });\nexit\n" > "./mongodb/$basedir/add_replicaset.js"
mongo -u __system -p "$(tr -d '\011-\015\040' < $keyFile)" --authenticationDatabase local < "./mongodb/$basedir/add_replicaset.js"


echo "starting mongodb on port $port"
mongod --config ./mongod.conf \
    --port $port \
    --unixSocketPrefix $pathPrefix \
    --pidfilepath $pidFilePath \
    --keyFile $keyFile \
    --dbpath $dbPath \
    --logpath "$logPath/mongodb.log"
echo $?
echo "mongodb stoped"