#!/bin/sh -e

PUID="${PUID:-9999}"
PGID="${PGID:-9999}"

groupadd -f -o -g $PGID ctbrec
[ $(getent passwd ctbrec) ] && usermod -d /app -g $PGID -u $PUID ctbrec || useradd -d /app -u $PUID -g $PGID -s /bin/sh ctbrec
getent passwd ctbrec

cd /app
export HOME=/app

# Check if config exists in /config, copy if not
[[ ! -e /app/config/server.json ]] && \
        cp /defaults/server.json /app/config/server.json

chown -R ctbrec:ctbrec /app
chmod -R 666 config && chmod -R 666 captures

ln -s /usr/lib/jvm/jdk/bin/java /usr/bin/java

su -p -c /app/start.sh ctbrec
