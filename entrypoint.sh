#!/bin/bash
MIN_MEMORY="128"
#CUSTOM_VARS
#VNC
n=alpine
b="\x1b[34m"
y="\x1b[33m"
g="\x1b[32m"
w="\x1b[37m"
a="\x1b[30;1m"
r="\x1b[31m"
reset="\x1b[0m"
CHECK=" ${b}●${w} Checking the current installation.${reset}"
BOOT=" ${b}●${w} Booting.${reset}"
DOWNLOAD=" ${b}●${w} Downloading image.${reset}"
PROVISION=" ${b}●${w} Provisioning.${reset}"
CHECK_DONE=" \033[1A\033[K${g}●${w} Checking the current installation.${reset}"
BOOT_DONE=" \033[1A\033[K${g}●${w} Booting.${reset}"
DOWNLOAD_DONE=" \033[1A\033[K${g}●${w} Downloading image.${reset}"
PROVISION_DONE=" \033[1A\033[K${g}●${w} Provisioning.${reset}"
BOOT_VNC=" \033[1A\033[K${g}●${w} Booting, vnc will be available at ${SERVER_IP}:${SERVER_PORT}${reset}"
cd /home/container || exit 1
echo "Starting VerseVM"
clear
sleep 0.2
curl -s --head --fail https://google.com > /dev/null || (echo -e " ${r}●${w} Network failed due to an unknown error, contact your provider."; sleep 2)
if [ "${SERVER_MEMORY}" -lt "${MIN_MEMORY}" ]; then
    echo -e " ${r}●${w} Server memory is less than ${MIN_MEMORY} Exiting.${reset}"
    exit 1
fi
if [ -n "$ADDITIONAL_PORTS" ] && ! [[ "$ADDITIONAL_PORTS" =~ ^[0-9]+( [0-9]+)*$ ]]; then
    echo -e " ${r}●${w} Your additional ports are invalid.${reset}"
    exit 1
fi
qemu_cmd="qemu-system-x86_64 -monitor unix:/home/container/qemu-monitor.sock,server,nowait -serial mon:stdio -drive file=${n,,}.qcow2,format=qcow2 -virtfs local,path=shared,mount_tag=shared,security_model=none -m ${SERVER_MEMORY} -net nic,model=virtio"
if [ ! -e "${n,,}.qcow2" ]; then
    echo -e "${DOWNLOAD}"
    wget --user-agent="versevm-imagedownloader" "https://github.com/rdpmakers/reforked-vvegg/raw/main/versevm/alpine.qcow2.gz" -O "${n}.qcow2.gz" > /dev/null 2>&1
    echo -e "${DOWNLOAD_DONE}"
    echo -e "${PROVISION}"
    gzip -d "${n}.qcow2.gz" > /dev/null 2>&1
    echo -e "${PROVISION_DONE}"
fi
echo -e "${BOOT}"
mkdir -p shared
if [ "$VNC" -eq 1 ]; then
    qemu_cmd+=" -vnc :$((SERVER_PORT - 5900)) -net user"
else
    qemu_cmd+=" -nographic -net user,hostfwd=tcp::${SERVER_PORT}-:22"
    IFS=' ' read -ra ports <<< "${ADDITIONAL_PORTS}"
    for port in "${ports[@]}"; do
        qemu_cmd+=",hostfwd=tcp::${port}-:${port}"
    done
fi

if [ -e "/dev/kvm" ]; then
    qemu_cmd+=" -enable-kvm -cpu host -smp $(nproc)"
else
    qemu_cmd+=" -cpu max,+avx -smp $(nproc)"
fi
if [ "$VNC" -eq 1 ]; then
    echo -e "${BOOT_VNC}"
    eval "$qemu_cmd" > /dev/null 2>&1
else
    echo -e "${BOOT_DONE}"
    eval "$qemu_cmd"
fi
