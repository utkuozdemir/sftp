FROM alpine:3.7
MAINTAINER Adrian Dvergsdal [atmoz.net]

# Steps done in one RUN layer:
# - Install packages
# - Fix default group (1000 does not exist)
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --no-cache bash shadow@community openssh openssh-sftp-server && \
    sed -i 's/GROUP=1000/GROUP=100/' /etc/default/useradd && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint /

EXPOSE 2222

RUN mkdir -p /etc/sftp/ && \
    echo "sftp-user:sftp-password:555:555:.pid,upload" > /etc/sftp/users.conf && \
    /entrypoint echo "created sftp-user..." && \
    rm /etc/sftp/users.conf && \
    chown -R 555:555 /etc/ssh && \
    chown 555:555 /etc/shadow

USER 555

ENTRYPOINT ["/usr/sbin/sshd", "-D", "-e"]