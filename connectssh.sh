#!/bin/bash
docker exec -it jammied-container ssh-keygen -R "[127.0.0.1]:2222" 
docker exec -it jammied-container sshpass -p "U23rP422w0rd" ssh -o StrictHostKeyChecking=no -p2222 user@127.0.0.1
