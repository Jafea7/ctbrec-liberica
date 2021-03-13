#!/bin/bash

# Check for config - copy if not found
[[ ! -e /app/config/server.json ]] && \
  cp /defaults/server.json /app/config/server.json

java -Xmx192m -cp ctbrec-server-4.1.0-final.jar -Dctbrec.config.dir=/app/config -Dctbrec.config=server.json ctbrec.recorder.server.HttpServer
