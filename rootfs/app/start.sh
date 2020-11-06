#!/bin/sh -e
cd /app

# Check if config exists in /config, copy if not
[[ ! -e /app/config/server.json ]] && \
  cp /defaults/server.json /app/config/server.json

[[ ! -e /app/ffmpeg/ffmpeg ]] && \
  ln -s /usr/bin/ffmpeg /app/ffmpeg/ffmpeg

chmod -R 666 config && chmod -R 666 captures

java -Xmx256m -cp ctbrec-server-3.10.4-final.jar -Dctbrec.config.dir=/app/config -Dctbrec.config=server.json ctbrec.recorder.server.HttpServer
