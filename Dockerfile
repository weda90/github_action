# Use a base image with Ubuntu or another suitable OS
FROM ubuntu:latest

# Install required packages
RUN apt-get update && \
    apt-get install -y wget libaio1 libncurses5 && \
    apt-get clean

# Download MySQL 5.6.46 from MySQL site and extract it
WORKDIR /tmp
RUN wget https://downloads.mysql.com/archives/get/p/23/file/mysql-5.1.73-linux-x86_64-glibc23.tar.gz && \
    tar -xvf mysql-5.1.73-linux-x86_64-glibc23.tar.gz && \
    mv mysql-5.1.73-linux-x86_64-glibc23 /usr/local/mysql && \
    rm mysql-5.1.73-linux-x86_64-glibc23.tar.gz

# Create mysql user group and user
RUN groupadd mysql && \
    useradd -g mysql mysql && \
    chown -R mysql:mysql /usr/local/mysql

# Initialize MySQL data directory
WORKDIR /usr/local/mysql
RUN scripts/mysql_install_db --user=mysql

# Set environment variables
ENV MYSQL_USER=root
ENV MYSQL_PASSWORD=secret
ENV MYSQL_PORT=3306
# Add environmental variable to automate the password prompt during installation
ENV MYSQL_ALLOW_EMPTY_PASSWORD=yes
ENV MYSQL_ROOT_PASSWORD=password

# Copy configuration file
COPY ./my.cnf /etc/my.cnf

RUN chmod 644 /etc/my.cnf
RUN mkdir -p /var/log/mysql
RUN chown mysql:mysql /var/log/mysql

# Create the directory for mysqld
RUN mkdir -p /var/run/mysqld/
# Set ownership of the directory to the mysql user and group
RUN chown -R mysql:mysql /var/run/mysqld/
# Set the permissions for the directory
RUN chmod 0755 /var/run/mysqld/

# Run mysql_install_db command during the container build process
RUN /usr/local/mysql/scripts/mysql_install_db --user=mysql --ldata=/var/lib/mysql

EXPOSE $MYSQL_PORT
# Start MySQL server
CMD ["bin/mysqld_safe", "--user=mysql"]
