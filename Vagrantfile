# -*- mode: ruby -*-
ABSFILE = File.absolute_path(__FILE__)
ABSDIR = File.dirname(ABSFILE)
COPS_DIR = File.join(ABSDIR, "local/corpusops.bootstrap")

# Edit this to the place of the corpusops vagrantfile
require "#{COPS_DIR}/hacking/vagrant/Vagrantfile_common.rb"

# load config
cfg = cops_init( :cwd => ABSDIR, :cops_path => COPS_DIR)

# install corpusops on localhost (a pre-packaged ansible)
cfg = cops_install(cfg)
cfg = cops_sync(cfg)

# add here post pre modification like names, subnet, etc
cfg = cops_configure(cfg)
cfg = cops_provider_configure(cfg)

# add here post common modification like modifying played ansible playbooks
# please use file variables to let users a way to call manually ansible
ansible_vars = {
    :extra_vars => "playbooks/variables/vbox.yml"
}

# install docker everywhere (MTU)
cfg = cops_inject_playbooks \
    :cfg => cfg,
    :playbooks => [{"playbooks/vbox_install_docker.yml" => ansible_vars}]

# install rancher server only on first box
cfg = cops_inject_playbooks \
    :cfg => cfg,
    :playbooks => [
        # install rancher server
        {"playbooks/vbox_server.yml" => ansible_vars},
        # base configure server & register the vbox itself as an agent
        {"playbooks/vbox_standalone.yml" => ansible_vars},
        # cleanup
        {"playbooks/vbox_rancher_cleanup.yml" => ansible_vars},
    ],
    :machine_num => cfg['MACHINE_NUM']
#
debug cfg.to_yaml
# vim: set ft=ruby ts=2 et sts=2 tw=0 ai:
