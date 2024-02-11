# Use a base image with Ubuntu or another suitable OS
FROM ubuntu:latest

# Install required packages and clean up after installation
RUN apt-get update && \
    apt-get install -y wget libaio1 libncurses5 && \
    rm -rf /var/lib/apt/lists/*

# Download MySQL 5.6.46 from MySQL site and extract it
WORKDIR /tmp
RUN wget https://downloads.mysql.com/archives/get/p/23/file/mysql-5.1.73-linux-x86_64-glibc23.tar.gz && \
    tar -xvf mysql-5.1.73-linux-x86_64-glibc23.tar.gz -C /usr/local/ && \
    rm mysql-5.1.73-linux-x86_64-glibc23.tar.gz

# Create mysql user group and user with the correct ownership settings
RUN groupadd mysql && \
    useradd -g mysql mysql && \
    chown -R mysql:mysql /usr/local/mysql

# Set environment variables
ENV MYSQL_USER=root
ENV MYSQL_PASSWORD=secret
ENV MYSQL_PORT=3306
ENV MYSQL_ROOT_PASSWORD=password
ENV MYSQL_ALLOW_EMPTY_PASSWORD=yes

# Copy configuration file and set permissions
COPY ./my.cnf /etc/my.cnf
RUN chmod 644 /etc/my.cnf

# Create necessary directories with correct ownership and permissions
RUN mkdir -p /var/log/mysql && \
    chown mysql:mysql /var/log/mysql && \
    mkdir -p /var/run/mysqld/ && \
    chown -R mysql:mysql /var/run/mysqld/ && \
    chmod 0755 /var/run/mysqld/

# Initialize MySQL data directory and set root password
RUN /usr/local/mysql/scripts/mysql_install_db --user=mysql --ldata=/var/lib/mysql && \
    /usr/local/mysql/bin/mysqladmin -u root password $MYSQL_ROOT_PASSWORD

# Expose the MySQL port
EXPOSE $MYSQL_PORT

# Start MySQL server using mysqld_safe script
CMD ["/usr/local/mysql/bin/mysqld_safe", "--user=mysql"]
