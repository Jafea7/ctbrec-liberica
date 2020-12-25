#!/bin/bash

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

# Use existing group if GID exists, create ctbrec if not
if [ $(getent group ${PGID} | cut -d: -f3) ]; then
  grp="$(getent group ${PGID} | cut -d: -f1)"
else
  addgroup --gid "${PGID}" --system ctbrec # || true
  grp="ctbrec"
fi

# Use existing user if UID exists, create ctbrec if not
if [ $(getent passwd ${PUID} | cut -d: -f1) ]; then
  usr="$(getent passwd ${PUID} | cut -d: -f1)"
else
  adduser --disabled-password --gecos "" --home /app --ingroup "$grp" --uid "${PUID}" ctbrec # || true
  usr="ctbrec"
fi

# Change owner/permissions of existing and new dirs/files
chown -R ${PUID}:${PGID} /defaults
chown -R ${PUID}:${PGID} /app
chmod g+s /app
cd /app
chmod -R 777 config && chmod -R 777 captures
chmod g+s config && chmod g+s captures

export HOME=/app

# Check for ffmpeg and java - copy/link if not found
[[ ! -e /app/ffmpeg/ffmpeg ]] && \
  ln -s /usr/bin/ffmpeg /app/ffmpeg/ffmpeg

[[ ! -e /usr/bin/java ]] && \
  ln -s /usr/lib/jvm/jdk/bin/java /usr/bin/java

# Start CTBRec
su -p -c /app/start.sh $usr
