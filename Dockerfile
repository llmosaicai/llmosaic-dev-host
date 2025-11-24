FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    SSH_USER=dev \
    SSH_UID=1000 \
    SSH_GID=1000

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    openssh-server \
    ca-certificates \
    curl wget \
    git \
    tar gzip bzip2 xz-utils unzip \
    build-essential \
    python3 python3-venv python3-pip \
    procps less nano \
    iproute2 dnsutils netcat-traditional \
    sudo \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/run/sshd /etc/ssh /home/${SSH_USER}/.ssh /workspace/repos

RUN groupadd -g ${SSH_GID} ${SSH_USER} \
 && useradd -m -d /home/${SSH_USER} -u ${SSH_UID} -g ${SSH_GID} -s /bin/bash ${SSH_USER}
RUN usermod -aG sudo ${SSH_USER} \
 && echo "${SSH_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-${SSH_USER} \
 && chmod 0440 /etc/sudoers.d/90-${SSH_USER}

# Install NVM + Node.js (LTS), and expose node/npm globally for convenience
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p "$NVM_DIR" \
 && curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
 && bash -lc "export NVM_DIR=$NVM_DIR; . $NVM_DIR/nvm.sh; nvm install 20; nvm alias default 20; node -v; npm -v" \
 && bash -lc 'ln -sf $(readlink -f "$NVM_DIR/versions/node/$(ls -1 $NVM_DIR/versions/node | sort -V | tail -n1)/bin/node") /usr/local/bin/node' \
 && bash -lc 'ln -sf $(readlink -f "$NVM_DIR/versions/node/$(ls -1 $NVM_DIR/versions/node | sort -V | tail -n1)/bin/npm") /usr/local/bin/npm' \
 && bash -lc 'ln -sf $(readlink -f "$NVM_DIR/versions/node/$(ls -1 $NVM_DIR/versions/node | sort -V | tail -n1)/bin/npx") /usr/local/bin/npx'

# Make NVM available for interactive shells (dev user)
RUN echo 'export NVM_DIR=/usr/local/nvm' > /etc/profile.d/nvm.sh \
 && echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> /etc/profile.d/nvm.sh \
 && chmod 0644 /etc/profile.d/nvm.sh
 # Ensure nvm is loaded for interactive shells (VS Code terminal)
RUN printf '\n# load nvm for interactive shells\nif [ -f /etc/profile.d/nvm.sh ]; then . /etc/profile.d/nvm.sh; fi\n' >> /etc/bash.bashrc \
 && printf '\n# nvm\nif [ -f /etc/profile.d/nvm.sh ]; then . /etc/profile.d/nvm.sh; fi\n' >> /home/${SSH_USER}/.bashrc \
 && chown ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.bashrc

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
 && chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}

VOLUME ["/workspace/repos"]
EXPOSE 22

CMD ["/entrypoint.sh"]
