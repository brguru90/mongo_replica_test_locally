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

START_FROM_PORT=27020
END_TO_PORT=27029

for i in $(seq $START_FROM_PORT $END_TO_PORT);
do   
    echo "creating service in port $i"
    bash ./create_service.sh $i $cur_dir $CUR_HOST $MASTER_HOST $MASTER_USERNAME $MASTER_PASSWORD
done

echo -e "rs.status();\nexit\n" > "$cur_dir/remove_replicaset.js"
mongo --username $MASTER_USERNAME --password $MASTER_PASSWORD --host $MASTER_HOST --authenticationDatabase admin <  $cur_dir/remove_replicaset.js

