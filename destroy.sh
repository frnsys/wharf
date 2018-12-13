#!/bin/bash

APP_NAME=$1
if [ -z $APP_NAME ]; then
    echo "Specify an app name"
    exit 1
fi

ansible-playbook -i hosts.ini destroy.yml -e "app_name=${APP_NAME}"
