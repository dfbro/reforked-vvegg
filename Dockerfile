FROM scratch
ADD alpine-minirootfs-3.21.3-x86_64.tar.gz /
CMD ["/bin/sh"]
RUN /bin/sh -c "apk add --update --no-cache ca-certificates bash qemu-system-x86_64 netcat-openbsd curl wget tzdata tini && adduser -D -h /home/container container"
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
STOPSIGNAL SIGINT
COPY ./entrypoint.sh /entrypoint.sh
CMD ["/bin/bash", "/entrypoint.sh"]
