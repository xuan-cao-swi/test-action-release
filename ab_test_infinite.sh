while [ 1 ]
do
    ab -n 2000 -c 10 http://0.0.0.0:8002/ &
    P1=$!
    ab -n 2000 -c 10 http://0.0.0.0:8003/ &
    P2=$!
    ab -n 2000 -c 10 http://0.0.0.0:8004/ &
    P3=$!
    wait $P1 $P2 $P3

    sleep 30m
done