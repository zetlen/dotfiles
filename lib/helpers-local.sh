#!/bin/sh
ssh-ha() {
  ssh -tt -p 22222 root@homeassistant.home.arpa $1
}
ssh-ha-container() {
	ssh-ha 'docker exec -it $(docker ps -qf "name='"$1"'") /bin/bash'
}
