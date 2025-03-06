#!/bin/bash
docker create \
  --name jammied-container \
  --restart always \
  -p 2222:2222 \
  -p 2096:2096 \
  -p 8443:8443 \
  --device /dev/kvm:/dev/kvm \
  -i -t \
  local:jammied

docker start jammied-container
