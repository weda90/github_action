# Use the latest Ubuntu image as the base
FROM ubuntu:latest

# add info created by me
LABEL Name=dev:python-3 \
    Version=0.0.1 \
    Maintainer="Weda Dewa <weda.dewa.yahoo.co.id>" \
    Description="Image Python developer on Ubuntu Linux."

# Update package lists and install necessary packages
RUN apt-get update && \
    apt-get install -y python3 python3-pip git && \
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the default command to run when a container is started
CMD ["bash"]
