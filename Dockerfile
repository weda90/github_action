FROM ubuntu:latest
LABEL Name=nodejs Version=0.0.1

ARG NODE_VERSION=--lts

RUN apt-get update && apt-get install -y \
  git \
  docker.io \
  curl \
  gnupg2 \
  ca-certificates \
  software-properties-common

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt update
RUN apt-cache policy docker-ce
RUN apt install -y docker-ce

# Install NVM only if NODE_VERSION is specified
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash \
    && \ 
    export NVM_DIR="$HOME/.nvm" \
    && \ 
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  \
    && \ 
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
    && \ 
    nvm install ${NODE_VERSION};

RUN apt install -y unzip
RUN curl -fsSL https://bun.sh/install | bash

CMD ["/bin/bash"]