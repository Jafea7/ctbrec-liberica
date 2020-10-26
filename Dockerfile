#
# ctbrec-liberica Dockerfile
#
# https://github.com/jafea7/ctbrec-liberica
#

# Pull base image.
FROM bellsoft/liberica-openjdk-alpine

# Update and install bash, ffmpeg, and mediainfo
RUN apk update
RUN apk add bash ffmpeg mediainfo

# Args: CTBRec version and memory required,
# (passed from build command)
ARG version
ARG memory

# Copy CTBRec server jar and playlist generator
COPY rootfs/ /
RUN chmod +x /playlist.sh

# Create ffmpeg folder and symlink to executable
# CTBRec expects it in /ffmpeg w.r.t. .jar file
# for single file recording
RUN mkdir /ffmpeg
RUN ln -s /usr/bin/ffmpeg /ffmpeg/ffmpeg

# Expose server non-SSL and SSL ports
EXPOSE 8080 8443

# Run command for the server
ENTRYPOINT ["java","-cp","/app.jar","-Xmx256m","-Dctbrec.config=server.json","ctbrec.recorder.server.HttpServer"]