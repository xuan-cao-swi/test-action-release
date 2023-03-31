# test-action-release

## Rails Memory benchmark

### Docker compose with docker stats




Build through docker compose
```
docker compose -f docker-compose-memory-benchmark.yml build
docker compose -f docker-compose-memory-benchmark.yml up
```

check the docker stats
```
docker stats
```

Build single images
```
docker build . -f Dockerfile_rails_mem -t rails_app_mem:latest
```

simulate the request

```
ab -n 100000 -c 100 http://rails_app_mem-1:8002/ &
ab -n 100000 -c 100 http://rails_app_without_apm_mem-1:8003/ &
```

simulate the request at same time
```
ab -n 100000 -c 100 http://rails_app_mem-1:8002/ &
P1=$!
ab -n 100000 -c 100 http://rails_app_without_apm_mem-1:8003/ &
P2=$!
wait $P1 $P2
```

```
ab -n 100000 -c 100 http://0.0.0.0:8002/ &
P1=$!
ab -n 100000 -c 100 http://0.0.0.0:8003/ &
P2=$!
wait $P1 $P2
```

curl http://rails_app_mem-1:8002/

curl http://rails_app_without_apm_mem-1:8003/ 


Install components for simulating
apt-get update && apt-get upgrade -y
apt install curl apache2-utils -y

Files:
```
docker-compose-memory-benchmark.yml
Dockerfile_rails_mem
Dockerfile_rails_mem_without_apm
```