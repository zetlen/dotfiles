#!/bin/sh
ssh_ha() {
  ssh -tt -p 22222 root@homeassistant.amberly $1
}
ssh_ha_container() {
	ssh_ha 'docker exec -it $(docker ps -qf "name='"$1"'") /bin/bash'
}
