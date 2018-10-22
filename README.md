# Docker Swarm Monitor

This is a fork from https://github.com/StefanScherer/swarm-monitor
Many Thanks to share this example with us.

[![This image on DockerHub](https://img.shields.io/docker/pulls/bee42/swarm-monitor.svg)](https://hub.docker.com/r/bee42/swarm-monitor/)

The Docker Swarm Monitor shows running containers (eg. replicas of a swarm service) with the Blinkt! LED strip.


| ARG             | Description         | Default               |
| :-------------- | :------------------ | :-------------------- |
| NODE_BASE_IMAGE | node base image     | node:8.12.0-stretch   |
| BASE_IMAGE      | Runtime base image  | node:8.12.0-alpine    |

```bash
$ docker build --build-arg NODE_BASE_IMAGE=hypriot/rpi-node:8.1.3 
  --build-arg BASE_IMAGE=hypriot/rpi-node:8.1.3-slim 
  -t bee42/swarm-monitor:linux-armv7-1.3.0
# or
$ docker build -f Dockerfile.arm -t bee42/swarm-monitor:linux-armv7-1.3.0 .
```

```
$ docker run -d \
  -v /sys:/sys \
  -v /var/run/docker.sock:/var/run/docker.sock \
  bee42/swarm-monitor:linux-armv7-1.3.0
```

ARM BUILD with 18.09 and the manifest tool

Use the >=18.06 experimenalt manifest tools

```
$  vi ~/.docker/config.json
{
  "stackOrchestrator" : "swarm",
  "experimental" :  "enabled"
}
```

```
$ docker manifest inspect node:8.12.0-stretch
$ docker manifest inspect node:8.12.0-alpine
$ docker build -t bee42/swarm-monitor:linux-amd64-1.3.0 .
$ docker build --no-cache \
 --build-arg=NODE_BASE_IMAGE=node@sha256:9f09b178301a9608e3c6bd8386cb9c17eae54f26cf72715b7c83ec48b2dadb79 \
 --build-arg=BASE_IMAGE=node@sha256:7c3cdff0f9f78740a932649156b72c76a310690cbb6628728e608b31a5f70b4e \
-t bee42/swarm-monitor:linux-armv7-1.3.0 .
```

```
$ docker-compose -f docker-compose-registry.yml up -d
$ docker tag bee42/swarm-monitor:linux-amd64-1.3.0 127.0.0.1:5000/bee42/swarm-monitor:linux-amd64-1.3.0
$ docker tag bee42/swarm-monitor:linux-armv7-1.3.0 127.0.0.1:5000/bee42/swarm-monitor:linux-armv7-1.3.0
$ docker push 127.0.0.1:5000/bee42/swarm-monitor:linux-amd64-1.3.0
$ docker push 127.0.0.1:5000/bee42/swarm-monitor:linux-armv7-1.3.0
$ docker manifest create --amend --insecure 127.0.0.1:5000/bee42/swarm-monitor:1.3.0 \
  127.0.0.1:5000/bee42/swarm-monitor:linux-amd64-1.3.0 \
  127.0.0.1:5000/bee42/swarm-monitor:linux-armv7-1.3.0
# fix arm
$ docker manifest annotate 127.0.0.1:5000/bee42/swarm-monitor:1.3.0 \
  127.0.0.1:5000/bee42/swarm-monitor:linux-armv7-1.3.0 \
  --arch arm --variant v7
$ docker manifest inspect --insecure 127.0.0.1:5000/bee42/swarm-monitor:1.3.0
$ docker manifest push --insecure 127.0.0.1:5000/bee42/swarm-monitor:1.3.0
$ docker login -u bee42
$ docker manifest push bee42/swarm-monitor:1.3.0
```

## Swarm Mode Demo

```
$ ip=$(ip -f inet -o addr show usb0|cut -d\  -f 7 | cut -d/ -f 1)
$ docker swarm init --advertise-addr $ip
$ docker service create --name monitor \
  --mode global \
  --restart-condition any \
  --mount type=bind,src=/sys,dst=/sys \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  bee42/swarm-monitor:1.3.0
```

Following env variables you can set:

```
--env SERVICE_IMAGE=bee42/whoami
--env SERVICE_VERSION_GREEN=1.2.0
--env SERVICE_VERSION_BLUE=linux-armv7-2.1.0
```

Create a service

```
$ docker service create --name whoami bee42/whoami:2.1.0
```

Scale service up and down

```
$ docker service scale whoami=4
$ docker service scale whoami=16
$ docker service scale whoami=32
```

![scale up](images/scale-up.gif)

Run a rolling update

```
$ docker service update --image bee42/whoami:1.2.0 \
  --update-parallelism 4 \
  --update-delay 2s \
  whoami
```

![scale up](images/rolling-update.gif)

Scale down

```
$ docker service scale whoami=1
```

![scale up](images/scale-down-to-one.gif)

Regards
Peter <@PRossbach>

## Links

* https://github.com/sealsystems/node-blinkt
