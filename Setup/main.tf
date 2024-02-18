resource "null_resource" "enable_ssh_keys" {
  connection {
    type     = "ssh"
    user     = var.username
    password = var.password
    host     = var.ip
    script_path = "${var.homedir}/terraform_%RAND%.sh"
  }



provisioner "remote-exec" {
    inline = [
     #SET Public Key
    "echo ${var.public_key} >> ${var.homedir}/.ssh/authorized_keys",
    #"echo ${var.password} | sudo -S sed -i 's/#PermitUserEnvironment no/PermitUserEnvironment yes/g' /etc/ssh/sshd_config",
    "echo ${var.password} | sudo -S apt-get update && sudo apt-get install ca-certificates curl gnupg -y",
    "sudo install -m 0755 -d /etc/apt/keyrings",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
    "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
    "echo \"deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    "sudo apt-get update && sudo apt-get install nfs-common docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y",
    "sudo groupadd docker",
    "sudo usermod -aG docker ${var.username}",
    "sudo useradd -u 1024 admin",
    "sudo usermod -g users admin",
    "echo ${var.password} | sudo -S passwd admin",
    "newgrp docker",
    "docker version",
    "sudo systemctl enable docker.service",
    "sudo systemctl enable containerd.service",
    "sudo systemctl add-wants default.target rpc-statd.service",
    "sudo systemctl enable rpc-statd",
    "sudo systemctl start rpc-statd",
    "sudo systemctl stop ufw",
    "sudo systemctl disable ufw",
    "sudo systemctl mask --now ufw",
    "sudo timedatectl set-ntp yes",
    "sudo timedatectl set-timezone Australia/Sydney",
    "rm -rf ${var.homedir}/*",
    "echo ${var.password} | sudo -S systemctl restart ssh",
    #fix DNS
    "sudo sed -i 's/#DNS=/DNS=${var.dns_server}/g' /etc/systemd/resolved.conf",
    "sudo systemctl restart systemd-resolved"
    ]
}

}