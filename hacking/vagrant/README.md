# helpers for a managed vagrant environment



Those helpers help you to control easily the current vagrant environment

- ssh.sh: helper to go inside the VM

- mount.sh: mount the VM root inside local/mountpoint via sshfs
- umount.sh: umount the local/mountpoint sshfs mountpoint

- export.sh: export a VM to a packaged box
- import.sh: import a VM from a packaged box


- sshgen.sh: generaetes .vagrant/cops-sshconfig, SSH config file to login inside a VM
- common.sh: commmon shell helpers
