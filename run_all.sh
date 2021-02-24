START_FROM_PORT=27019
END_TO_PORT=27040

for i in $(seq $START_FROM_PORT $END_TO_PORT);
do
   echo "Welcome $i times"
   bash ./run.sh $i &
   sleep 2
done