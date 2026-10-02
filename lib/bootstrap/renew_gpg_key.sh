#!/usr/bin/env bash
# Extend the expiry of the zetlen GPG key (primary and all subkeys) and
# refresh the public key exported to this repo.
#
# Usage: renew_gpg_key.sh [duration]   (default: 2y; any gpg expiry spec works)
set -euo pipefail

FPR=DA4F61CB3B1C7572561CE6DED4887C25BD67E87C
DURATION="${1:-2y}"
PUBKEY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/gpg_z_pub.asc"

if ! gpg --list-secret-keys "$FPR" &>/dev/null; then
	echo "Secret key $FPR is not on this machine; renew from one that has it." >&2
	exit 1
fi

# Fingerprints of every subkey, including expired ones.
mapfile -t SUBKEYS < <(
	gpg --with-colons --with-subkey-fingerprints --list-options show-unusable-subkeys \
		--list-secret-keys "$FPR" |
		awk -F: '$1 == "ssb" { want = 1; next } want && $1 == "fpr" { print $10; want = 0 }'
)

echo "Extending primary key expiry by $DURATION..."
gpg --quick-set-expire "$FPR" "$DURATION"

if ((${#SUBKEYS[@]})); then
	echo "Extending ${#SUBKEYS[@]} subkey(s) by $DURATION..."
	gpg --quick-set-expire "$FPR" "$DURATION" "${SUBKEYS[@]}"
fi

gpg --armor --export "$FPR" >"$PUBKEY"

# Mark our own key as ultimately trusted (ownertrust 6) so gpg stops
# reporting it as [ unknown]. Idempotent.
echo "$FPR:6:" | gpg --import-ownertrust

gpg --list-options show-unusable-subkeys --list-secret-keys "$FPR"

cat <<EOF
Exported updated public key to $PUBKEY.

Still to do by hand:
  - Commit $PUBKEY.
  - Replace the key at https://github.com/settings/keys (and keys.openpgp.org if used).
  - On other machines: gpg --import $PUBKEY
EOF
