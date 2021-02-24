START_FROM_PORT=27019
END_TO_PORT=27080

for i in $(seq $START_FROM_PORT $END_TO_PORT);
do
   
    if [ -n "$1" ]
    then
        echo "kill $i"
        fuser -k $i/tcp
    else
        echo "Run on $i"
        bash ./run.sh $i &
        sleep 2
    fi
done