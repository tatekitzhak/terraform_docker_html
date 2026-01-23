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
