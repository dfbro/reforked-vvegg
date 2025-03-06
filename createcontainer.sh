#!/bin/bash
docker create \
  --name jammied-container \
  --restart always \
  --network host \
  --device /dev/kvm:/dev/kvm \
  -i -t \
  local:jammied

docker start jammied-container
