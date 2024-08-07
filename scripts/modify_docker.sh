#!/usr/bin/env bash

if [ $1 == "down" ]; then
    echo "Removing Docker Registry"
    # Check if Docker is running
    docker info > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        docker rm -f registry && \
        osascript -e 'quit app "Docker"'
    fi
    exit 0
fi
if [ $1 == "up" ]; then
    echo "Configuring Docker Registry"
    open -a Docker && \
    sleep 10
    docker run -d -p 5000:5000 --restart always --name registry registry:2
    exit 0
fi
