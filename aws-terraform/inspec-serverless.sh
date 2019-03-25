#!/bin/bash

# Install docker & nano
sudo yum -y install docker nano git

# Start docker
systemctl start docker && systemctl enable docker

# Setup node.js repo
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -

# Install node.js
sudo yum -y install nodejs

# Installing the serverless cli
npm install -g serverless

# Clone inspec-serverless repo
git clone https://github.com/martezr/serverless-inspec.git

# Change directory
cd serverless-inspec

# Change branch
git checkout feature/native-aws

# Build gem dependencies
chmod +x build.sh && sh ./build.sh

# Change directory
cd code

# Deploy stack
sls deploy
