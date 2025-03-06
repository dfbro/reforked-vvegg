FROM scratch
ADD alpine-minirootfs-3.21.3-x86_64.tar.gz /
CMD ["/bin/sh"]
RUN /bin/sh -c "apk add --update --no-cache sshpass openssh-client ca-certificates bash qemu-system-x86_64 qemu-img netcat-openbsd curl wget tzdata tini"
WORKDIR /root
STOPSIGNAL SIGTERM
COPY ./entrypoint.sh /entrypoint.sh
CMD ["/bin/bash", "/entrypoint.sh"]
