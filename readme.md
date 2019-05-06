# wharf

A system for managing and provisioning Docker containers on a remote host using Ansible.

I developed this to quickly deploy multiple client projects to a server without worrying about polluting the server with conflicting dependencies or anything like that.

---

## Initial server setup for `WHARF_HOST`

`wharf` has only been tested on Ubuntu 18.04, but it should work on any system that supports Ansible and Docker. These instructions are for Ubuntu specifically.

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

1. Install Ansible: `pip install ansible`
2. Create `authorized_keys` in the `docker` folder (in this repo) with your public SSH key. This public key will be set as an authorized key for the Docker container, which gives Ansible access to provision it.
3. In your `/etc/environment` file (or wherever else you define environment variables), define an env var called `WHARF_HOST` which should be set to the host server IP or hostname, and one called `WHARF_USER` which is the user to login to `WHARF_HOST` as.
4. Add your public SSH key to the `WHARF_HOST` server.
5. Copy this repo to `/opt/wharf/`.
6. Symlink the `wharf` script to a more convenient location, e.g. `/usr/local/bin/`:

```
sudo ln -s /opt/wharf/wharf /usr/local/bin/wharf
```

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

To follow container logs:

```
wharf log <APP NAME>
```

To start a `bash` shell in an app container:

```
wharf bash <APP NAME>
```

To clean dangling docker images:

```
wharf clean
```

---

## How it works

Note on hosts: the parent host (the server, `WHARF_HOST`) is `wharf`, and the target Docker container is `container`.

1. Creates a base Docker image on `WHARF_HOST` with Ansible and SSH installed, and runs a script at `/usr/share/start.sh` (if you want to, for example, start a Flask application, you should create your own `start.sh` and overwrite the default one in your `<APP PLAYBOOK>`)
2. Creates `container` with the specified `<APP NAME>`, then exposes its SSH port to port 8888 on `WHARF_HOST` (so that Ansible can access it)
3. Uses the specified `<APP PLAYBOOK>` to deploy to the `WHARF_HOST`'s port 8888 (i.e. to `container`)
4. Unbinds the container's SSH port from `WHARF_HOST`'s port 8888 and binds its port 8000 (assumed port your service is running on) to the specified `<APP PORT>` of `container`
5. Mounts `/var/log/<APP NAME>` as `container`'s `/var/log` so logs are persisted on the host system
6. Setup nginx (w/ HTTPS/SSL) for the specified `<DOMAIN NAME>`, passing traffic to the specified `<APP PORT>`

---

## Tips

- Make sure your web service uses the host `0.0.0.0` and port `8000`.

---

## Example

A simple Flask playbook is included at `example/playbook.yml`.

TODO: update the example to use uwsgi/supervisor

---

# MIT License

Copyright 2019 Francis Tseng

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.