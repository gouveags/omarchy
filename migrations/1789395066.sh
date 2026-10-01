echo "Disable Limine mouse input so pointer movement cannot cancel autoboot"

limine_conf=/boot/limine.conf

sudo /usr/bin/bash -euo pipefail -c '
source /usr/lib/limine/limine-mutex

mutex_lock
trap mutex_unlock EXIT

limine_conf=$1
[[ -f $limine_conf ]] || exit 0
if awk "
  /^[[:space:]]*\// { exit }
  tolower(\$0) ~ /^[[:space:]]*mouse:/ { found = 1; exit }
  END { exit !found }
" "$limine_conf"; then
  # A run that inserted the line and then failed to enroll is retried, so enroll what it left
  [[ $(head -n 1 "$limine_conf") == "mouse: no" ]] || exit 0
else
  sed -i "1i mouse: no" "$limine_conf"
fi
# With ENABLE_ENROLL_LIMINE_CONFIG=yes, a config edit without re-enrolling fails the boot checksum
limine-enroll-config
' _ "$limine_conf"
