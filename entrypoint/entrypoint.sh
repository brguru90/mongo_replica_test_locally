#!/bin/bash
healthcheck_basedir="/mongo_recovery"

touch /entrypoint/exit_status

# cmd_out=$(mongo  --host $MONGODB_INITIAL_PRIMARY_HOST --authenticationDatabase admin --username root --password $MONGODB_INITIAL_PRIMARY_ROOT_PASSWORD --quiet  --eval "var check_host = '$CUR_HOST'"  $healthcheck_basedir/mongo_replica_health_check.js)
# echo $cmd_out
# if  echo $cmd_out | grep -q "needs to reset replica" -i; then
#     echo "resetting replica"
#     rm -rf /mongodb/data/db
#     mkdir -p /mongodb/data/db
# fi

# ----------------- repairing sync based on last exit  status------------------

valid_signal=(143 130 131 148 137)
prev_exit_status=$(cat /entrypoint/exit_status)
echo "prev_exit_status=$prev_exit_status"

for i in "${arr[@]}"
do
    if [ "$i" -eq $prev_exit_status ] ; then
        echo "Restting DB based on exit code"
        rm -rf /mongodb/*
    fi
done
#-------------------------------------------


# --------------- creating missing paths ----------------

mkdir -p /mongodb  
mkdir -p /mongodb/data/db
mkdir -p /mongodb/tmp
mkdir -p /mongodb/logs
touch /mongodb/logs/mongodb.log

#-------------------------------------------

echo $MONGODB_REPLICA_SET_KEY > /mongodb/key.txt
# sed -i "s/primary_main_db/$MONGODB_REPLICA_SET_NAME/g" ./mongod.conf

# ---------------- setting required file permissions


chmod 770 -R /mongodb /entrypoint
chown 1001:mongodb -R /mongodb /entrypoint
chmod 500  /mongodb/key.txt
ls -lR /mongodb
ls -lR /entrypoint

#_---------------------------------------------




echo "starting mongodb"
echo "0" > /entrypoint/exit_status
mongod --config /entrypoint/mongod.conf
exit_status=$? 
echo $exit_status > /entrypoint/exit_status
echo "mongodb stoped"

cat /mongodb/logs/mongodb.log
sleep 10

exit $exit_status