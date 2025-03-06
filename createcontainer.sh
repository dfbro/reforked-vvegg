#!/bin/bash
docker create \
  --name jammied-container \
  --restart always \
  -p 2222:2222 \
  --device /dev/kvm:/dev/kvm \
  -i -t \
  local:jammied

docker start -i jammied-container
