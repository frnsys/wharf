FROM ubuntu:18.04

RUN apt update
RUN apt upgrade -y

# Ansible
RUN apt install -y python python-pip

# rsync for Ansible's synchronize module
RUN apt install -y rsync

# vim for convenience
RUN apt install -y vim

# Setup SSH
RUN apt install -y openssh-server
RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh
COPY authorized_keys /root/.ssh/authorized_keys
EXPOSE 22

# Assume service will run on port 8000
EXPOSE 8000

# Set locales
RUN apt install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Start SSH and default start script
COPY start.sh /usr/share/start.sh
RUN chmod 775 /usr/share/start.sh
ENTRYPOINT service ssh restart && /usr/share/start.sh
