#!/bin/sh -e
cd /app

java -Xmx256m -cp ctbrec-server-3.10.4-final.jar -Dctbrec.config.dir=/config -Dctbrec.config=server.json ctbrec.recorder.server.HttpServer