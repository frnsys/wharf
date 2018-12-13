#!/bin/bash

APP_NAME=$1
APP_PORT=$2
APP_PLAYBOOK=$3
DOMAIN_NAME=$4
LETSENCRYPT_EMAIL=$5
if [ -z $APP_NAME ]; then
    echo "Specify an app name"
    exit 1
fi
if [ -z $APP_PORT ]; then
    echo "Specify an app port"
    exit 1
fi
if [ -z $APP_PLAYBOOK ]; then
    echo "Specify an app playbook path"
    exit 1
fi
if [ -z $DOMAIN_NAME ]; then
    echo "Specify a domain name"
    exit 1
fi
if [ -z $LETSENCRYPT_EMAIL ]; then
    echo "Specify a Let's Encrypt email address"
    exit 1
fi

ansible-playbook -i hosts.ini deploy.yml \
    -e "app_name=${APP_NAME}" \
    -e "app_port=${APP_PORT}" \
    -e "app_playbook=${APP_PLAYBOOK}" \
    -e "domain_name=${DOMAIN_NAME}" \
    -e "letsencrypt_email=${LETSENCRYPT_EMAIL}"
