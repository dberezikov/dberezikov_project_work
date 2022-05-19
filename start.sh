#!/bin/bash

echo "Welcome to IaC interface!"
echo " "
echo "# Gitlab runner install"
read -p "Please input gitlab url (example, https://gitlab.com): " GITLAB_URL
read -p "Please input gitlab token: " GITLAB_TOKEN
DIR="ansible/tokens"
if [ ! -d "$DIR" ]; then
  mkdir $DIR
else  
echo $GITLAB_URL > $DIR/gitlab_url
fi
echo $GITLAB_TOKEN > $DIR/gitlab_token
echo " "
echo "# Let's start building the infrastructure..." 
sleep 5
echo " "
cd terraform && terraform apply --auto-approve
