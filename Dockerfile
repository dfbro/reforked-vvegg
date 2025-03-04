CMD ["/bin/bash" "/entrypoint.sh"]
COPY ./entrypoint.sh /entrypoint.sh
STOPSIGNAL SIGINT
WORKDIR /home/container
ENV USER=container HOME=/home/container
USER container
RUN /bin/sh -c apk add --update --no-cache ca-certificates bash qemu-system-x86_64 netcat-openbsd curl wget tzdata tini && adduser -D -h /home/container container
CMD ["/bin/sh"]
ADD alpine-minirootfs-3.21.3-x86_64.tar.gz /
