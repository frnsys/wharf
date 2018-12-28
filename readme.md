# wharf

A system for managing and provisioning Docker containers on a remote host using Ansible.

I developed this to quickly deploy multiple client projects to a server without worrying about polluting the server with conflicting dependencies or anything like that.

---

## Initial server setup

```
sudo apt update
sudo apt upgrade -y

# Ansible requirements
sudo apt install -y python python-pip
sudo pip install docker-py # 2.7; for 3 use "docker"

# Install Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce

# Install nginx
sudo apt install -y nginx
```

---

## Usage

To deploy an application:

```
./deploy.sh <APP NAME> <APP PORT> <APP PLAYBOOK> <DOMAIN NAME> <LETSENCRYPT EMAIL>

# Example
./deploy.sh example-project 8001 example/playbook.yml foo.site.com foo@foo.com
```

To destroy an application:

```
./destroy.sh <APP NAME>
```

---

## How it works

Note on hosts: the parent host (the server) is `wharf`, and the target Docker container is `container`.

1. Creates a base Docker image with Ansible and SSH installed, and runs a script at `/usr/share/start.sh` (if you want to, for example, start a Flask application, you should create your own `start.sh` and use Ansible to overwrite the default one)
2. Creates a container with the specified `<APP NAME>`, then exposes its SSH port to port 8888 on the host machine
3. Uses the specified `<APP PLAYBOOK>` to deploy to the host machine's port 8888 (i.e. to the Docker container)
4. Unbinds the container's SSH port from the host's port 8888 and binds port 8000 (assumed port your service is running on) to the specified app port
5. Setup nginx (w/ HTTPS/SSL) for the specified domain name, passing traffic to the specified app port