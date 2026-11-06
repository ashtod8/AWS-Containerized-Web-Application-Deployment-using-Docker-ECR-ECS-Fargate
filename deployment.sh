#!/bin/bash


# PROJECT: AWS Containerized Web Application Deployment
# SERVICES: EC2, Docker, Amazon ECR, ECS Fargate
# OS: Ubuntu 24.04

# PART 1: INSTALL DOCKER ON UBUNTU EC2 INSTANCE

# Update package repositories
sudo apt update -y

# Install Docker
sudo apt install docker.io -y

# Check Docker service status
sudo systemctl status docker

# Add current user to Docker group
sudo usermod -aG docker $USER

# Activate Docker group without logging out
newgrp docker

# PART 2: DOWNLOAD APACHE HTTPD IMAGE

# Search for Apache HTTP Server images
docker search httpd

# Pull the latest Apache HTTP Server image
docker pull httpd:latest

# Display downloaded Docker images
docker images


# PART 3: CREATE WEBSITE FILES

# Create HTML directory
mkdir -p html

# Create website homepage
nano html/index.html

# Paste your HTML code and save the file:
# CTRL + O -> ENTER -> CTRL + X



# PART 4: CREATE DOCKERFILE

# Create Dockerfile
nano Dockerfile

# Add the following instructions inside Dockerfile:
#
# FROM httpd:latest
# COPY ./html /usr/local/apache2/htdocs


# PART 5: BUILD AND RUN DOCKER CONTAINER

# Build custom Docker image
docker build -t mysite .

# Verify Docker image creation
docker images

# Run container with port mapping and resource limits
docker run -dit \
    -p 80:80 \
    --cpus 0.256 \
    --memory 64MB \
    --name c1 \
    mysite

# Check container status
docker ps -a

# Access website using EC2 public IP address


# PART 6: STOP DOCKER CONTAINER

# Stop the running container
docker stop c1

# Verify container status
docker ps -a

# Website should no longer be accessible

# PART 7: INSTALL AWS CLI ON EC2

# Install unzip utility
sudo apt install unzip -y

# Download AWS CLI version 2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "awscliv2.zip"

# Extract AWS CLI installation package
unzip awscliv2.zip

# Install AWS CLI
sudo ./aws/install

# PART 8: TAG AND PUSH IMAGE TO AMAZON ECR

# ECR login (Step 1, 3, 4 from AWS push commands)
