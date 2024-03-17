#!/bin/sh
set -e

PATH=/opt/sbin:/opt/bin:$PATH
export PATH

mkdir -p /etc/freeradius

cat > /etc/raddb/users <<EOF
user Cleartext-Password := "password"
EOF

cat > /etc/raddb/clients.conf <<EOF
client dockernet {
	ipaddr = *
	secret = testing123
}
EOF



# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    set -- radiusd -X "$@"
fi

# check for the expected command
if [ "$1" = 'radiusd' ]; then
    shift
    exec radiusd -f -X "$@"
fi

# debian people are likely to call "freeradius" as well, so allow that
if [ "$1" = 'freeradius' ]; then
    shift
    exec radiusd -f -X "$@"
fi

# else default to run whatever the user wanted like "bash" or "sh"
exec "$@"