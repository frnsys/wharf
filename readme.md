# wharf

A system for managing and provisioning Docker containers on a remote host using Ansible.

I developed this to quickly deploy multiple client projects to a server without worrying about polluting the server with conflicting dependencies or anything like that.

---

## Initial server setup

```
sudo apt update
sudo apt upgrade -y

# Ansible requirements
sudo apt install -y python python-pip python-setuptools
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

## Control machine setup

1. Create `authorized_keys` in `docker` with your public SSH key.
2. In your `/etc/environment` file (or wherever else you define environment variables), define an env var called `WHARF_HOST` which should be set to the host server IP or hostname.
3. Add your public SSH key to the `WHARF_HOST` server.
4. Copy this repo to `/opt/wharf/`.
3. Symlink the `wharf` script to a more convenient location, e.g. `/usr/local/bin/`:

    sudo ln -s /opt/wharf/wharf /usr/local/bin/wharf

---

## Usage

To deploy an application:

```
wharf deploy <APP NAME> <APP PLAYBOOK> <DOMAIN NAME>:<APP PORT>

# Example
wharf deploy example-project example/playbook.yml foo.site.com:8001
```

Note that `<APP PORT>`s must be unique for a server.

To destroy an application:

```
wharf destroy <APP NAME>
```

To see what containers are deployed:

```
wharf ls
```

---

## How it works

Note on hosts: the parent host (the server, `WHARF_HOST`) is `wharf`, and the target Docker container is `container`.

1. Creates a base Docker image with Ansible and SSH installed, and runs a script at `/usr/share/start.sh` (if you want to, for example, start a Flask application, you should create your own `start.sh` and overwrite the default one in your `<APP PLAYBOOK>`)
2. Creates a container with the specified `<APP NAME>`, then exposes its SSH port to port 8888 on the host machine
3. Uses the specified `<APP PLAYBOOK>` to deploy to the host machine's port 8888 (i.e. to the Docker container)
4. Unbinds the container's SSH port from the host's port 8888 and binds port 8000 (assumed port your service is running on) to the specified `<APP PORT>`
5. Mounts `/var/log/<APP NAME>` as the container's `/var/log` so logs are persisted on the host system
6. Setup nginx (w/ HTTPS/SSL) for the specified `<DOMAIN NAME>`, passing traffic to the specified `<APP PORT>`

---

## Tips

- Make sure your web service uses the host `0.0.0.0` and port `8000`.
- To start a bash shell in a running container: `docker exec -it <CONTAINER NAME> bash` (on the `wharf` server)
- To view the logs of a container: `docker logs -t <CONTAINER NAME>` (on the `wharf` server)

---

## Example

A simple Flask playbook is included at `example/playbook.yml`.

TODO: update the example to use uwsgi/supervisor