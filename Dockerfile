FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    SSH_USER=dev \
    SSH_UID=1000 \
    SSH_GID=1000

RUN apt-get update \
 && apt-get install -y --no-install-recommends openssh-server ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/run/sshd /etc/ssh /home/${SSH_USER}/.ssh /workspace/repos

RUN groupadd -g ${SSH_GID} ${SSH_USER} \
 && useradd -m -d /home/${SSH_USER} -u ${SSH_UID} -g ${SSH_GID} -s /bin/bash ${SSH_USER}

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
 && chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}

VOLUME ["/workspace/repos"]
EXPOSE 22

CMD ["/entrypoint.sh"]

