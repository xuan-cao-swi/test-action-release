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
docker build . -f Dockerfile_rails_mem_with_otel -t rails_mem_with_otel:latest
```

Start containers
```
docker run  -it --rm --name sample-alpine rails_mem_with_otel:latest
```

### Simulate the request

#### without ab

curl http://rails_app_mem-1:8002/

curl http://rails_app_without_apm_mem-1:8003/ 

curl http://0.0.0.0:8002/

#### with ab

```
ab -n 100000 -c 100 http://rails_app_mem-1:8002/ &
ab -n 100000 -c 100 http://rails_app_without_apm_mem-1:8003/ &
```

#### simulate the request at same time
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

### Install AB

Install components for simulating
apt-get update && apt-get upgrade -y
apt install curl apache2-utils -y

Files:
```
docker-compose-memory-benchmark.yml
Dockerfile_rails_mem
Dockerfile_rails_mem_without_apm
```

### Monitor the stats and output graph

start the docker container
run ab_test_infinite.sh
run monitor_docker_stats.py
