# AWS Containerized Web Application Deployment using Docker, Amazon ECR & ECS Fargate

## Project Overview

This project demonstrates the end-to-end deployment of a containerized static web application on AWS using Docker, Amazon Elastic Container Registry (ECR), and Amazon Elastic Container Service (ECS) with AWS Fargate.

The application is initially hosted on an Ubuntu 24.04 EC2 instance using an Apache HTTP Server Docker container. A custom Docker image is then created, authenticated, and pushed to a private Amazon ECR repository. Finally, the image is deployed on Amazon ECS using the Fargate launch type, allowing the website to run without managing EC2 instances for container hosting.

The project covers containerization, image management, IAM-based authentication, container orchestration, and serverless container deployment.

## AWS Services and Technologies Used

| Technology | Purpose |
|---|---|
| Amazon EC2 | Provides the Ubuntu environment for initial Docker setup and image creation. |
| Ubuntu 24.04 | Operating system used on the EC2 instance. |
| Docker | Containerizes the static web application. |
| Apache HTTP Server | Serves the HTML website inside the container. |
| Amazon ECR | Stores the custom Docker image in a private repository. |
| AWS IAM | Provides permissions for EC2 to authenticate with ECR. |
| AWS CLI | Interacts with AWS services and authenticates Docker with ECR. |
| Amazon ECS | Manages container deployment and orchestration. |
| AWS Fargate | Runs containers without requiring management of EC2 container instances. |

## Project Implementation

### Phase 1: Launch and Configure EC2 Instance

1. Open the AWS Management Console.
2. Navigate to Amazon EC2.
3. Launch a new EC2 instance.
4. Select Ubuntu Server 24.04 LTS as the AMI.
5. Select an existing key pair.
6. Select an existing security group.
7. Launch the instance.
8. Connect to the instance using SSH.

**SSH username:**

```bash
ubuntu
```

### Phase 2: Install Docker

Update the Ubuntu package repositories and install Docker.

```bash
sudo apt update -y

sudo apt install docker.io -y
```

Check the Docker service status:

```bash
sudo systemctl status docker
```

Add the current user to the Docker group:

```bash
sudo usermod -aG docker $USER

newgrp docker
```

This allows the current user to execute Docker commands without using sudo.

### Phase 3: Download Apache HTTP Server Image

Search for the Apache HTTP Server image:

```bash
docker search httpd
```

Download the latest image:

```bash
docker pull httpd
```

Verify the downloaded image:

```bash
docker images
```

### Phase 4: Create the Website

Create a directory for the website files:

```bash
mkdir html
```

Copy the project's `index.html` into the directory:

```bash
cp index.html html/index.html
```

The HTML file contains the static website with:

- Header section
- Navigation bar
- Welcome section
- About section
- Services section
- Contact section
- Footer

### Phase 5: Create Dockerfile

Create a file named `Dockerfile` in the project root directory.

```dockerfile
FROM httpd:latest

COPY ./html /usr/local/apache2/htdocs
```

**Explanation:**

- `FROM httpd:latest` – Uses the official Apache HTTP Server image as the base image.
- `COPY ./html /usr/local/apache2/htdocs` – Copies the website files into Apache's default document root.

### Phase 6: Build and Run Docker Container

Build the custom Docker image:

```bash
docker build -t mysite .
```

Verify image creation:

```bash
docker images
```

Run the container:

```bash
docker run -dit \
  -p 80:80 \
  --cpus 0.256 \
  --memory 64MB \
  --name c1 \
  mysite
```

**Command explanation:**

| Parameter | Description |
|---|---|
| `-d` | Runs the container in detached mode. |
| `-i` | Keeps standard input open. |
| `-t` | Allocates a pseudo-terminal. |
| `-p 80:80` | Maps host port 80 to container port 80. |
| `--cpus 0.256` | Limits CPU usage to 0.256 CPU units. |
| `--memory 64MB` | Limits container memory to 64 MB. |
| `--name c1` | Assigns the container name `c1`. |
| `mysite` | Specifies the Docker image. |

Verify the running container:

```bash
docker ps -a
```

Open the following address in a browser:

```text
http://EC2-PUBLIC-IP
```

The website should now be accessible through the EC2 instance's public IP address.

### Phase 7: Stop the Docker Container

Stop the running container:

```bash
docker stop c1
```

Verify the container status:

```bash
docker ps -a
```

Refresh the website using the EC2 public IP.

The website should no longer be accessible because the Apache container has stopped.

### Phase 8: Configure IAM Role for ECR Access

Create an IAM role to allow the EC2 instance to access Amazon ECR.

**Configuration:**

- Trusted entity: AWS Service
- Use case: EC2
- Role name: `ec2-access-ecr`
- Permission policy: `AmazonEC2ContainerRegistryFullAccess`

Attach the IAM role to the EC2 instance:

1. Navigate to EC2 Instances.
2. Select the Ubuntu instance.
3. Open Actions.
4. Select Security.
5. Select Modify IAM role.
6. Assign `ec2-access-ecr`.

The IAM role allows the EC2 instance to obtain temporary AWS credentials through the instance profile instead of configuring permanent access keys.

### Phase 9: Create Amazon ECR Repository

Navigate to Amazon Elastic Container Registry (ECR).

1. Select Private repository.
2. Create a repository.
3. Repository name: `mysite`.
4. Create the repository.

The private repository stores the custom Docker image that will be deployed on ECS.

### Phase 10: Install AWS CLI

Connect to the EC2 instance using SSH.

Update the package repositories:

```bash
sudo apt update -y
```

Install unzip:

```bash
sudo apt install unzip -y
```

Download AWS CLI version 2:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

Extract the installation package:

```bash
unzip awscliv2.zip
```

Install AWS CLI:

```bash
sudo ./aws/install
```

Verify the installation:

```bash
aws --version
```

### Phase 11: Authenticate Docker with Amazon ECR

Authenticate Docker using the AWS CLI:

```bash
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com
```

Replace `AWS_ACCOUNT_ID` with your actual AWS account ID.

This command retrieves an authentication token from ECR and passes it to Docker for registry authentication.

### Phase 12: Push Docker Image to Amazon ECR

Tag the local Docker image with the ECR repository URI:

```bash
docker tag mysite:latest AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/mysite:latest
```

Push the image to Amazon ECR:

```bash
docker push AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/mysite:latest
```

After the upload is successful, navigate to the ECR repository and verify that the image is available.

Once the image has been successfully pushed, the EC2 instance can be terminated because the container image is stored in ECR.

### Phase 13: Create Amazon ECS Fargate Cluster

Navigate to Amazon ECS.

1. Select Clusters.
2. Choose Create cluster.
3. Enter the cluster name: `cluster1`.
4. Select AWS Fargate as the infrastructure option.
5. Create the cluster.

ECS provides the orchestration layer for deploying and managing containers.

### Phase 14: Create ECS Task Definition

Navigate to Task Definitions and create a new task definition.

**Configuration:**

| Setting | Value |
|---|---|
| Task definition family | FG-TD |
| Launch infrastructure | AWS Fargate |
| Container name | mysite |
| Image URI | Amazon ECR image URI |
| CPU and memory | Configure suitable Fargate task resources |
| Container port | 80 |

Paste the ECR image URI into the container image field.

Configure the task execution role with the necessary ECR image-pull permissions, such as `AmazonECSTaskExecutionRolePolicy`.

Create the task definition.

The task definition specifies the container image, resource allocation, networking-related configuration, and execution settings required to run the application.

### Phase 15: Create ECS Fargate Service

Open the previously created ECS cluster.

1. Navigate to Services.
2. Select Create.
3. Choose AWS Fargate as the launch type.
4. Select task definition family `FG-TD`.
5. Enter service name `FG-service1`.
6. Configure the desired number of tasks.
7. Configure networking and select the appropriate VPC and subnets.
8. Select the existing security group `Linux-SG`.
9. Enable public IP assignment.
10. Create the service.

**Security group requirement:**

Allow inbound HTTP traffic on TCP port 80 from the required client IP ranges. Restrict SSH access to trusted IP addresses when applicable.

The ECS service maintains the desired number of running tasks and manages their deployment.

### Phase 16: Verify Fargate Deployment

Navigate to:

ECS → Clusters → cluster1 → Services → Tasks.

Select the running task and locate its public IP address under networking details.

Open the following address in a browser:

```text
http://FARGATE-TASK-PUBLIC-IP
```

The website should now be accessible through the public IP address assigned to the Fargate task.

This confirms that the custom Docker image was successfully retrieved from ECR and deployed through ECS Fargate.

## Repository Structure

```text
aws-docker-ecr-ecs-fargate-deployment/
│
├── screenshots/
│   ├── 01-ec2-instance.png
│   ├── 02-iam-role.png
│   ├── 03-ecr-repository.png
│   ├── 04-ecs-cluster-service.png
│   ├── 05-fargate-task.png
│   └── 06-deployed-website.png
│
├── index.html
├── Dockerfile
├── deployment.sh
└── README.md
```

The `Dockerfile` should be added to the repository. The `deployment.sh` file contains the Linux shell commands used during the implementation. AWS Console operations are performed separately.

## Screenshots

The `screenshots` directory contains visual evidence of the deployment process.

| Screenshot | Description |
|---|---|
| EC2 Instance | Running Ubuntu EC2 instance. |
| IAM Role | IAM role configured with ECR permissions. |
| ECR Repository | Private ECR repository containing the Docker image. |
| ECS Cluster and Service | Active ECS cluster and Fargate service. |
| Fargate Task | Running ECS task and deployment details. |
| Deployed Website | Website successfully accessed through the Fargate public IP. |

## Key Learning Outcomes

Through this project, I gained practical experience with:

- Launching and configuring Ubuntu EC2 instances.
- Connecting to Linux instances using SSH.
- Installing and managing Docker on Ubuntu.
- Creating custom Docker images using Dockerfiles.
- Running containers with port mapping and resource constraints.
- Understanding Docker images versus running containers.
- Configuring IAM roles and permissions.
- Installing and using AWS CLI.
- Authenticating Docker with Amazon ECR.
- Pushing container images to a private registry.
- Creating ECS clusters, task definitions, and services.
- Deploying containers using AWS Fargate.
- Accessing containerized applications through public IP networking.


## Conclusion

This project demonstrates a complete container deployment workflow on AWS, starting with Docker-based website hosting on EC2 and progressing to image storage in Amazon ECR and application deployment using Amazon ECS Fargate.

It provides practical exposure to containerization, cloud infrastructure, IAM-based authentication, container orchestration, and serverless container computing.
