# Tutorial Guide: Terraform, Docker containers, Static HTML page

## A step-by-step guide to Terraform basics: Deploying a static HTML page via Docker containers on your local machine.


To implement this project, we will use Terraform to automate the creation of a Docker image containing your static HTML page and then launch it as a container.

Prerequisites
- Terraform CLI installed on your machine.
- Docker Desktop (or Docker Engine) running locally.
- A basic code editor (like VS Code).

## Step 1: Prepare Your Project Files
Create a new directory for your project and add an `index.html` file.

`index.html`

`HTML`
``` bash
<!DOCTYPE html>
<html>
<head>
    <title>Terraform Docker Lab</title>
</head>
<body>
    <h1>Hello from Terraform and Docker!</h1>
    <p>This static page was deployed using Infrastructure as Code.</p>
</body>
</html>
```

Create a `Dockerfile` in the same directory to define how to build your image:

`Dockerfile`

``` bash
# Use Nginx as the base image
FROM nginx:alpine
# Copy our static file to the Nginx html directory
COPY index.html /usr/share/nginx/html/index.html
```

## Step 2: Write the Terraform Configuration
Create a file named `main.tf`. This is where you tell Terraform to interact with Docker.
``` bash
main.tf

Terraform
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  # For Linux/macOS, use unix socket. For Windows, use npipe:////./pipe/docker_engine
  host = "unix:///var/run/docker.sock"
}

# 1. Define the Docker Image to build
resource "docker_image" "my_static_site" {
  name = "my-local-webpage:v1"
  build {
    context = "." # Look in the current directory for the Dockerfile
  }
}

# 2. Create the Docker Container
resource "docker_container" "web_server" {
  name  = "terraform-web-container"
  image = docker_image.my_static_site.image_id
  
  ports {
    internal = 80
    external = 8080 # This maps http://localhost:8080 to the container
  }
}
```
## Step 3: Run Terraform Basics

`terraform init -> terraform validate -> terraform plan -> terraform apply -> terraform destroy`

Now, open your terminal in that directory and follow the standard Terraform workflow.

1. Initialize (`terraform init`)
This downloads the Docker provider plugin so Terraform can talk to your Docker engine.

Bash
`terraform init`

2. `terraform fmt` - the Terraform CLI that automatically reformats your Terraform configuration files (.tf) to a canonical format and style.

2. `terraform validate`

3. Plan (terraform plan)
This shows you what Terraform intends to do. It will tell you it's going to build one image and create one container.

Bash
`terraform plan`

4. Apply (`terraform apply`)
This executes the plan. When prompted, type yes.

Bash
`terraform apply`

## Step 4: Verify Your Work
- Check Docker: Run `docker ps` in your terminal. You should see `terraform-web-container` running.

- View the Page: Open your browser and go to `http://localhost:8080`. You should see your "Hello from Terraform" page!

Cleanup
When you’re done, you can tear everything down (stop and remove the container and image) with one command:

5. State - The command used to list the resource addresses for all resources currently managed by the Terraform state file. It provides an overview of the infrastructure that Terraform knows about, which is useful for inspection and managing complex configurations. 
Bash: `terraform state list`

6. `terraform state show aws_instance.web_app`
Bash:

7. `terraform destroy`