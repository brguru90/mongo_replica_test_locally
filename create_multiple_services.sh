full_path=$(realpath $0)
cur_dir=$(dirname $full_path)

if ! whoami | grep -q "root" -i; then
    echo "Plaese run it as root user"
    exit
fi

echo $cur_dir

CUR_HOST="127.0.0.1"
START_FROM_PORT=27019
END_TO_PORT=27021

for i in $(seq $START_FROM_PORT $END_TO_PORT);
do   
    bash ./create_multiple_services.sh $i $cur_dir $CUR_HOST 
done