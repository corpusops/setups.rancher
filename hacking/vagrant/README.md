# Generic Vagrant setup for a corpusops compatible VM

Generic multibox shell & ansible (corpusops based) vagrant setup framework

## needed vagrant plugins
- Run this command before any provisionning
```sh
vagrant plugins install vagrant-share vagrant-vbguest
vagrant plugins update
```


## MACHINE_NUM is the only variable you need to setup on multiple corpusops setups
- default is 1
- This control various settings and should be unique per VM & HOST as
  it controls the private IP network
- When you want to configure change it, ``$EDITOR vagrant_config.yml``
```yaml
---
MACHINE_NUM: 2
```

## vagrant_config.yml settings file
- Most of the variables including played playbooks can be overriden <br/>
    by editing the ``vagrant_config.yml`` file, read the Vagrantfile

## control
- [./manage](./manage): <br>/
  main entry point
    - **up**: start (create) the vm & mount
    - **down**: umount && stop the vm
    - **ssh**: helper to go inside the VM
    - **sshgen**: helper to generate a ssh client config file
    - **mount**: mount the VM root to local/mountpoint via sshfs
    - **umount**: umount the local/mountpoint sshfs mountpoint
    - **export**: export a VM to a packaged box
    - **import**: import a VM from a packaged box
- [./common.sh](./common.sh):<br/>
  commmon shell helpers

### Scripts related to the vagrant provisioning
- [./Vagrantfile](./Vagrantfile):<br/>
  Vagrantfile to contruct the vm
- The provisioning procedure consists in:
    - execute the pre provision script
        - sync authorized keys from ubuntu to root
        - install corpusops
    - play ansible playbooks
    - execute the post provision script
- Vagrant shell provision pre/post helpers that are executed before|after the ansible setp :
    - [./provision_pre.sh](./provision_pre.sh):
      used before ansible setup, early setup (install ansible through corpusops)
    - [./provision_post.sh](./provision_post.sh):<br/>
      post provision steps like cleaning the vm files
    - [./sudo-ansible-playbook.sh](./sudo-ansible-playbook.sh):<br/>
      wrapper to execute corpusops ``ansible-playbook`` as root


### Bring this setup inside your app
- Place the whole folder inside a subfolder of your repository
- Tweak ansible setup (``ANSIBLE_VARS``, ``PLAYBOOKS`` (2 places !))
- Symlink the vagrantfile to /Vagrantfile
- You are done

