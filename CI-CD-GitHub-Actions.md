# CI/CD Pipeline using Terraform, Docker and GitHub Actions 🚀
## A step-by-step guide to Terraform basics: Deploying a static HTML page via Docker containers on your local machine.

### Tags
`#docker` `#aws` `#cicd` `#github-actions` `#ec2-instance`

# 📖 Overview
By following this guide, you will establish a fully automated CI/CD pipeline. 
The workflow follows this logic: `Code ➔ GitHub ➔ Docker Image ➔ Docker Hub ➔ AWS EC2 ➔ Run Container`

- CI Phase: Automatically builds a Docker image of your code and pushes it to Docker Hub.
- CD Phase: Pulls the latest image onto an AWS EC2 instance and executes the container.

# 🛠️ Step 1: Create a Dockerfile
Create a `Dockerfile` in your root directory. This example uses a Flask application


``` bash
FROM python:3-alpine3.15 

WORKDIR /app 

COPY . /app 
RUN pip install -r requirements.txt 

EXPOSE 8000 

CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]   
```

Tip: Always run and test your container locally first using `docker build` and `docker run` to ensure the application starts correctly.

# ⚙️ Step 2: GitHub Actions Workflow Configuration
Create a `.github/workflows` folder in your repository. You will need two files: 
1. `ci.yml` 
2. `cd.yml`

### 1. CI Pipeline (`ci.yml`)
This triggers on every push to the `main` branch. It logs into Docker Hub, builds the image, and pushes it.

### Required GitHub Secrets:
Inside `ci.yml` we will need to write some conditions that will trigger GitHub actions when to run that file. Secondly, all the subsequent steps will create a docker image and push it to the docker hub. We will need to add two secrets to GitHub secrets

- `DOCKER_USERNAME`: Your Docker Hub username.

- `DOCKER_PASSWORD`: Your Docker Hub password or Access Token.

``` bash
name: CI pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    name: Create docker image
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Login DockerHub
        env:
          DOCKER_USERNAME: ${{secrets.DOCKER_USERNAME}}
          DOCKER_PASSWORD: ${{secrets.DOCKER_PASSWORD}}
        run: docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

      - name: Build the Docker image
        run: docker build -t flaskapp-image .

      - name: Tag image
        run: docker tag flaskapp-image ${{secrets.DOCKER_USERNAME}}/flaskapp-image:0.0.1

      - name: Push to Docker Hub
        run: docker push ${{secrets.DOCKER_USERNAME}}/flaskapp-image:0.0.1
```

### 2. CD Pipeline (cd.yml)
This triggers automatically once the CI pipeline successfully completes.

### Required GitHub Secrets:
Inside `cd.yml` we will write the script that will connect with our ec2 instance, pull the docker image from the docker hub, delete the running container, and finally run our latest pulled image. To ensure the functioning of this we must incorporate some more secrets: 

- `HOST_DNS`: Public DNS of your EC2 instance.

- `EC2_SSH_KEY`: Your private `.pem` key content.

- `USERNAME`: The EC2 user (usually `ubuntu` or `ec2-user`).

``` bash
name: CD pipeline

on:
  workflow_run:
    workflows: ["CI pipeline"]
    types:
      - completed

jobs:
  deploy:
    name: Deploy to EC2
    runs-on: ubuntu-latest
    steps:
      - name: Executing remote ssh commands
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.HOST_DNS }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            sudo docker pull ${{ secrets.DOCKER_USERNAME }}/flaskapp-image:0.0.1
            sudo docker rm -f sample-container || true
            sudo docker run -d -p 8000:8000 --name sample-container ${{ secrets.DOCKER_USERNAME }}/flaskapp-image:0.0.1
```
After incorporating these two files into our repository, the CI/CD pipeline is finalized. Upon committing, navigate to the 'Actions' tab, under 'Workflows,' you will observe two distinct workflows: the CI pipeline and the CD pipeline. As long as there is a new commit our pipeline will be triggered, and will start building the image and eventually it will deployed. 

# ✅ Verification
- Commit & Push: Once you push these files, go to the Actions tab in GitHub.

- Monitor: You will see the CI pipeline start, followed by the CD pipeline.

- Check EC2: SSH into your instance and run:

Bash
`sudo docker ps -a`

Your container `sample-container` should be running and active