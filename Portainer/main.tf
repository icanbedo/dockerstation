terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}


provider "docker" {
  host = "ssh://${var.username}@${var.ip}"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

resource "docker_image" "portainer_image" {
  name = var.PortainerImage
}

resource "docker_image" "portainer_agent_image" {
  name = "portainer/agent:latest"
  }

# Create a container
resource "docker_container" "portainer_container" {
  image = docker_image.portainer_image.image_id
  destroy_grace_seconds = 30
  name  = "portainer"
   command = [
     "--sslcert", "/certs/${var.CertificateName}.crt","--sslkey", "/certs/${var.CertificateName}.key"
   ]
   ports {
     internal = 9443
     external = 9443
     ip = var.ip
     protocol = "tcp"
   }
   restart = "always"
   volumes {
     container_path = "/data"
     host_path = var.ContainerPath
   }
   volumes {
     container_path = "/certs"
     host_path = "${var.CertificatePath}"
   }
}

# Create a container
resource "docker_container" "portainer_agent_container" {
  image = docker_image.portainer_agent_image.image_id
  destroy_grace_seconds = 30
  name  = "portainer-agent"
   ports {
     internal = 9001
     external = 9001
     ip = var.ip
     protocol = "tcp"
   }
   restart = "always"
   volumes {
     container_path = "/data"
     host_path = var.ContainerPath
   }
   volumes {
     container_path = "/var/run/docker.sock"
     host_path = "/var/run/docker.sock"
   }
   volumes {
     container_path = "/var/lib/docker/volumes"
     host_path = "/var/lib/docker/volumes"
   }
   volumes {
     container_path = "/host"
     host_path = "/"
   }
}

