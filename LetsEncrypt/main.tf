terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
     remote = {
      source = "tenstad/remote"
    }
  }
}

provider "acme" {
   
  server_url = var.Staging ? "https://acme-staging-v02.api.letsencrypt.org/directory" : "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "reg_private_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.reg_private_key.private_key_pem
  email_address   = var.emailAddress
}

resource "tls_cert_request" "req" {
  private_key_pem = tls_private_key.cert_private_key.private_key_pem
  dns_names       = var.certSANNames
  
  subject {
    common_name = var.certCommonName
  }
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  certificate_request_pem = tls_cert_request.req.cert_request_pem
  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_DNS_API_TOKEN = var.cloudFlareAPIToken
    }
  }

}


resource "null_resource" "folderpath" {
  connection {
    type = "ssh"
    user = var.username
    password = var.password
    host = var.ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "echo ${var.password} | sudo -S mkdir -p ${var.CertificatePath}",   
      "sudo chmod 777 ${var.CertificatePath}"
     ]
  }
}

#create files from provider output and upload
resource "remote_file" "certificate_pem" {
  conn {
    host        = var.ip
    user        = var.username
    password = var.password
  }

  path = "${var.CertificatePath}/${var.CertificateName}.crt"
  #generates a fullchain pem
  content = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
}

resource "remote_file" "key_pem" {
  conn {
    host        = var.ip
    user        = var.username
    password = var.password
  }

  path = "${var.CertificatePath}/${var.CertificateName}.key"
  content = "${tls_cert_request.req.private_key_pem}"
}

