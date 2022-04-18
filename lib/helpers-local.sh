#!/bin/sh
ssh-ha() {
  ssh -tt -p 22222 root@homeassistant.amberly $1
}
ssh-ha-container() {
	ssh-ha 'docker exec -it $(docker ps -qf "name='"$1"'") /bin/bash'
}
