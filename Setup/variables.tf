variable "ip" {
  description = "Host ip address"
  type        = string
}
variable "username" {
  description = "Host username"
  type        = string
}

variable "dns_server" {
  description = "DNS Server"
  type        = string
}

variable "password" {
  description = "Host user password"
  type        = string
  sensitive   = true
}

variable "emailAddress" {
  description = "LetsEncrypt Email Address"
  type        = string
}

variable "certCommonName" {
  description = "Certificate Common Name"
  type        = string
}

variable "certSANNames" {
  description = "Certificate SAN Names"
}

variable "cloudFlareAPIToken" {
  description = "Cloudflare DNS API Token"
  sensitive = true
}

variable "CertificatePath" {
  description = "Path to write certificate"
}

variable "CertificateName" {
  description = "Name of Certificate File"
}

variable "Staging" {
  type = bool
  description = "Use Staging Servers! Set to False for Prod Certificate"
  default = true
}

variable "public_key" {
  description = "Your SSH Public Key"
  type        = string
}
variable "homedir"{
  description = "Your User Homedir"
  type        = string
}

variable "PortainerImage" {
  description = "Portainer Image"
  type        = string
}

variable "ContainerPath" {
  description = "Local Container Path"
  type        = string
}

