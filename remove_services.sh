full_path=$(realpath $0)
cur_dir=$(dirname $full_path)

if ! whoami | grep -q "root" -i; then
    echo "Plaese run it as root user"
    exit
fi


MASTER_HOST="localhost"
MASTER_USERNAME="root"
MASTER_PASSWORD="root"
CUR_HOST="127.0.0.1"

START_FROM_PORT=27019
END_TO_PORT=27040

for i in $(seq $START_FROM_PORT $END_TO_PORT);
do   
    echo -e "rs.remove('$CUR_HOST:$i');\nexit\n" > "$basedir/remove_replicaset.js"
    mongo --username $MASTER_USERNAME --password $MASTER_PASSWORD --host $MASTER_HOST --authenticationDatabase admin <  $basedir/remove_replicaset.js
    service_file1="mongo_replica_on_port_$i.service"
    service_file2="mongo_replica_add_port_$i.service"
    systemctl stop $service_file1
    systemctl disable $service_file1
    systemctl stop $service_file2
    systemctl disable $service_file2
    rm -f /lib/systemd/system/service_file1 /lib/systemd/system/service_file2
    rm -f /etc/systemd/system/service_file1 /etc/systemd/system/service_file2
done

# mongo  --authenticationDatabase admin --username root --password Cisco@123
