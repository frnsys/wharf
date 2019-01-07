FROM ubuntu:18.04

RUN apt update
RUN apt upgrade -y

# Ansible
RUN apt install -y python python-pip

RUN apt install -y rsync

# Setup SSH
RUN apt install -y openssh-server
RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh
COPY authorized_keys /root/.ssh/authorized_keys
EXPOSE 22

# Assume service will run on port 8000
EXPOSE 8000

# Start SSH and default start script
COPY start.sh /usr/share/start.sh
RUN chmod 775 /usr/share/start.sh
ENTRYPOINT service ssh restart && /usr/share/start.sh
