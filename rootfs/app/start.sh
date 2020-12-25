#!/bin/bash

# Check for config - copy if not found
[[ ! -e /app/config/server.json ]] && \
  cp /defaults/server.json /app/config/server.json

java -Xmx256m -cp ctbrec-server-3.10.10-final.jar -Dctbrec.config.dir=/app/config -Dctbrec.config=server.json ctbrec.recorder.server.HttpServer
