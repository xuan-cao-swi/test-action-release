ab -n 10000 -c 100 http://0.0.0.0:8002/ &
P1=$!
ab -n 10000 -c 100 http://0.0.0.0:8003/ &
P2=$!
ab -n 10000 -c 100 http://0.0.0.0:8004/ &
P3=$!
wait $P1 $P2 $P3
echo "yes"
echo "ok"
echo "y"
