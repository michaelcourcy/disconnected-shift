#execute on the host 
vagrant ssh-config workstation > .ssh/sshw
vagrant ssh-config node1 > .ssh/ssh1
vagrant ssh-config node2 > .ssh/ssh2
vagrant ssh-config master > .ssh/sshm
alias sshw='ssh -F .ssh/sshw workstation'
alias ssh1='ssh -F .ssh/ssh1 node1'
alias ssh2='ssh -F .ssh/ssh2 node2'
alias sshm='ssh -F .ssh/sshm master'
