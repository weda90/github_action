# Use the latest Ubuntu image as the base
ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

# Add info created by me
LABEL Name=dev:python-3 \
 Version=0.0.1 \
 Maintainer="Weda Dewa <weda.dewa@yahoo.co.id>" \
 Description="Image Python developer on Ubuntu Linux."

# Update package lists and install necessary packages
RUN apt-get update && \
    apt-get install -y python3 python3-pip git && \
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common 

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu focal stable" && \
    apt-get update && \
    apt-get install -y docker-ce
    
RUN apt-get clean && \
 rm -rf /var/lib/apt/lists/*

RUN  ln -s /usr/bin/python3 /usr/bin/python

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
RUN export PATH="/root/.local/bin:$PATH"

# Set the default command to run when a container is started
CMD ["bash"]
