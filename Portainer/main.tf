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

# Create a container
resource "docker_container" "portainer_container" {
  image = docker_image.portainer_image.image_id
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
     container_path = "/var/run/docker.sock"
     host_path = "/var/run/docker.sock"
   }
   volumes {
     container_path = "/certs"
     host_path = "${var.CertificatePath}"
   }
}
