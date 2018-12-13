#!/bin/bash

echo "Started"
touch /tmp/hello_world
python3 -m http.server
