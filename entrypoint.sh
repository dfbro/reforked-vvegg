#!/bin/bash

# Function to gracefully stop QEMU when the container is stopping
cleanup() {
    echo "Container is stopping, sending ACPI shutdown to QEMU..."
    echo "system_powerdown" | nc -U /tmp/qemu-monitor.sock
}

# Trap SIGTERM (sent by `docker stop`)
trap cleanup SIGTERM

cd /root
if [ ! -e /root/jammy.qcow2 ]; then
  wget -O /root/jammy.qcow2 https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
  qemu-img resize /root/jammy.qcow2 +22G
  wget -O /root/config.img https://github.com/rdpmakers/freeroot-KVM/raw/refs/heads/main/user-data.img
  mkdir /qemu-share
fi
sh -c "qemu-system-x86_64 -monitor unix:/tmp/qemu-monitor.sock,server,nowait -serial mon:stdio -drive file=/root/jammy.qcow2,format=qcow2 -drive file=/root/config.img,format=raw -device virtio-net-pci,netdev=n0 -netdev user,id=n0,hostfwd=tcp::2222-:22,hostfwd=tcp::2082-:2082,hostfwd=tcp::8443-:8443 -smp 4 -m 7G -enable-kvm -cpu host -virtfs local,path=/qemu-share,mount_tag=shared,security_model=none,id=shared -nographic | tee /opt/KVM.log" &

# Wait for QEMU to exit
wait $!
