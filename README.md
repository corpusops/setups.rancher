# Rancher corpusops ansible based setup

## Corpusops doc (deployment)

### Setup variables
```sh
export A_GIT_URL="https://gitlab.makina-corpus.net/irstea/dinamis.git"
export COPS_CWD="$HOME/makina/irstea/dinamis"
export NONINTERACTIVE=1
# VM NOT DONE
export FTP_URL=<tri>@ftp.makina-corpus.net:/srv/projects/makina_commun/data/commun/nobackup/vm_bar/*-*box
```
### Clone the project
- Note the **--recursive** switch; if you follow the next commands, you can then skip this step on the next docs.

    ```sh
    git clone --recursive $A_GIT_URL $COPS_CWD
    cd $COPS_CWD
    # Maybe: git checkout -b <branch>
    git submodule init
    git submodule update
    .ansible/scripts/download_corpusops.sh
    .ansible/scripts/setup_ansible.sh
    ```

### Deploy the dev VM
- [corpusops vagrant doc](https://github.com/corpusops/corpusops.bootstrap/blob/master/doc/projects/vagrant.md)<br/>
  or ``local/corpusops.bootstrap/doc/projects/vagrant.md`` after corpusops.bootstrap download.

### Deploy on enviromnents
- Setup needed when you dont have Ci setup for doing it for you
- [corpusops deploy doc](https://github.com/corpusops/corpusops.bootstrap/blob/master/doc/projects/deploy.md)<br/>
  or ``local/corpusops.bootstrap/doc/projects/deploy.md`` after corpusops.bootstrap download.


## Vagrant setup for test VMs
- [See generic vagrant notes](./hacking/vagrant/README.md)
- you need to do multiple time ``up`` on fist time as <br/>
  rancher may need some time to bring up
- We provide a setup to deploy a single node rancher (controller+agent) [doc](hacking/vagrant)

    ```sh
    git clone  https://github.com/corpusops/setups.rancher.git
    cd setups.rancher
    vagrant up
    ```

- You can hack the ``vagrant_config.yml`` file (eg: override the PLAYBOOKS var to setup elseway the rancher roles)
- To login on your rancher host, see the ``local`` folder after provisionning:

    ```sh
    ./vm_manage ssh
    # cat local/mountpoint/etc/rancher/rancher_env
    # cat local/mountpoint/etc/rancher/ranchercompose_default_env
    ```

- To access the rancher ui, you can use two ways:
    - With a ssh tunnel, just use [http://localhost:8080](http://localhost:8080)

            ```sh
            hacking/vagrant/ssh.sh -L 8080:localhost:8080
            ```

    - Or with the private network address:

            ```sh
            echo $RANCHER_URL
            ```

- ``rancher`` & ``rancher-compose`` utilities are installed inside the vm, use them from there

    ```sh
    ./vm_manage ssh
    . /etc/rancher/ranchercompose_default_env
    docker ps
    rancher ps
    ```


## Deploy & manage rancher clusters with docker & ansible (NOT VAGRANT)

### prerequisites
#### on control machine:
- corpusops
- kubectl if deploying k8s environment
- Install with:

```
bin/install.sh
# OPT:
cd local/corpusops.bootstrap
bin/cops_apply_role roles/corpusops.roles/localsettings_kubectl/role.yml
```

#### Create ansible inventory

- Create a regular ansible inventory with all of your variables and <br/>
  use the appropriate ``-i`` switch on your commands
- Eg create ``local/inventory``

```

```

- Then  ``local/*/bin/ansible -i $abspath/inventory all -m ping``

#### on remote machines
- python
- systemd
- docker-ce >= 17.09.0-ce
- docker-compose >= 1.16.1
- Installation can be done with corpusops on ubuntu:

```
cd local/corpusops.bootstrap
bin/ansible-playbook -i $abspath/inventory roles/corpusops.roles/services_virt_docker/role.yml
```

## configure server node
### inventory
- [server variables](playbooks/roles/server/defaults/main.yml)

### access your cluster
- By default we configure rancher to listen on localhost:8080
- TIP: You can access it remotly with a ssh tunnel:
    -

      ```sh
      ssh -L 12345:localhost:8080 myrancherbaremetal
      ```

    - open http://localhost:12345

### First run, dont forget to lock your rancher admin with a user
- Go to admin/access control and configure authentication !!!
- EG:
    - choose a login/password
    - click local
    - save

## configure agent node
### inventory
- [agent variables](playbooks/roles/agent/defaults/main.yml)

### Eg: deploy an agent to register a standalone k8s node

- vars if using docker compose and your agent is colocated with the server (same machine)

```ini
[rancheragent:vars]
corpusops_rancher_agent_labels=etcd=true&orchestration=true&compute=true
corpusops_rancher_agent_base_url=http://foobar.com:8080/v1
corpusops_rancher_agent_token=xxx:yyy:zzz
```

- vars if using docker compose and your agent is colocated with the server (same machine)

```ini
[rancheragent:vars]
corpusops_rancher_agent_labels=etcd=true&orchestration=true&compute=true
corpusops_rancher_agent_host_ip=192.168.1.2
corpusops_rancher_agent_base_url=http://{{corpusops_rancher_agent_host_ip}}:8080/v1
corpusops_rancher_agent_token=xxx:yyy:zzz
corpusops_rancher_agent_collocated=1
```

## Typical workflow to create a kubernetes cluster
- Create a rancher server
- Configure authentication on the server
- Create one or more rancher agents with environment: ``"CATTLE_HOST_LABELS='etcd=true&orchestration=true&compute=true"``
    - ``etcd=true``: etcd plane node
    - ``controller=true``: controller plane node
    - ``compute=true``: compute plane node
- Configure a kubernetes environment on the server and link those node onto the environment

## Note on sharing the same host for the server and the agent
This use can is common on development boxes.

Be aware that the agent has a 3way register step and that the containers that launch the registration scripts are not in the same network that the remaining container which use the network start of your baremetal host.

Thus, The easiest way to make the registration process suceed is to ell your baremetal host to use a name for "localhost" that you will share and also use inside the "companions containers". This name can be either an hostname or a fqdn, we recommend using a FQDN.
