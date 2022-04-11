#!/bin/bash

#install script for github self hosted runner because github's is lacking docker installer and permssion sets
#Best ran in home folder of runner user to avoid permissions hell

#get runner token to pass later
#Note that the token is unique to each project and needs to be input by the user, they can get the token from github runner setting
#web address should look like https://github.com/UserName/ProjectName/settings/actions/runners/
read -p "Please input your runner token (can be found in runner settings for project in github)" gitToken
read - "Please enter full github url..." giturl
#update packages
sudo apt update -y && sudo apt upgrade -y

#make sure docker pre-req are installed
sudo apt install ca-certificates curl gnupg lsb-release

#Add docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

#set docker to install from stable branch
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#Update again to make sure docker repo is working
sudo apt update -y

#install docker
sudo apt install docker-ce docker-ce-cli containerd.io -y

#Giver currently logged in user permission for docker
sudo usermod -a -G docker $USER

#restart docker so user permission loads
sudo systemctl restart docker.service

#Create runner folder
mkdir actions-runner && cd actions-runner

#Download latest runner package
curl -o actions-runner-linux-x64-2.289.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.289.1/actions-runner-linux-x64-2.289.1.tar.gz

#extract installer
tar xzf ./actions-runner-linux-x64-2.289.1.tar.gz

#Create the runner and start the configuration experiance (uses token prompted for at beggining)
./config.sh --url $giturl --token $gitToken

#start the runner
./run.sh