#!/bin/sh

export BACKUP_SERVER="lake.in.the-z-machine.com"
export BACKUP_SERVER_MAC="2c:41:38:a9:53:fb"

wake_lake() {
  __wol $BACKUP_SERVER_MAC && __ping_until_up
}

__wol() {
  if i_have wol; then
    wol "$BACKUP_SERVER_MAC"
  elif i_have wakeonlan; then
    wakeonlan "$BACKUP_SERVER_MAC"
  else
    echo "No wakeonlan client installed. Install wol or wakeonlan." >&2
    return 1
  fi
  printf "Sent WOL packet to $BACKUP_SERVER at $BACKUP_SERVER_MAC.\n"
}

__ping_until_up() {
  wake_timeout="${1:-60}"
  printf "Pinging $BACKUP_SERVER until up.\n"
  printf 'Waiting %s before timing out...' $wake_timeout >&2
  if timeout $wake_timeout bash <<EOT; then
  while ! ping -q -c 1 -W 1 $BACKUP_SERVER 2>&1 > /dev/null; do printf '.'; done;
EOT
    printf '%s is up!\n' $BACKUP_SERVER >&2
  else
    printf '%s is not responding after %s!\n' $BACKUP_SERVER $wake_timeout >&2
    return 1
  fi
}
