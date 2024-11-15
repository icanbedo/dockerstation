resource "null_resource" "enable_ssh_keys" {
  connection {
    type     = "ssh"
    user     = var.username
    password = nonsensitive(var.password)
    host     = var.ip
    script_path = "${var.homedir}/terraform_%RAND%.sh"
    agent = true
  }



provisioner "remote-exec" {
    inline = [
     #SET Public Key
    "echo ${var.public_key} >> ${var.homedir}/.ssh/authorized_keys",
    "echo ${nonsensitive(var.password)} | sudo -S sed -i 's/#PermitUserEnvironment no/PermitUserEnvironment yes/g' /etc/ssh/sshd_config",
    "echo ${nonsensitive(var.password)} | sudo -S apt-get update && sudo apt-get install ca-certificates curl gnupg -y",
    "echo ${nonsensitive(var.password)} | sudo -S install -m 0755 -d /etc/apt/keyrings",
    "echo ${nonsensitive(var.password)} | sudo -S curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo -S gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
    "echo ${nonsensitive(var.password)} | sudo -S chmod a+r /etc/apt/keyrings/docker.gpg",
    "echo \"deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    "echo ${nonsensitive(var.password)} | sudo -S apt-get update && sudo apt-get install nfs-common docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y",
    "echo ${nonsensitive(var.password)} | sudo -S groupadd docker",
    "echo ${nonsensitive(var.password)} | sudo -S usermod -aG docker ${var.username}",
    "echo ${nonsensitive(var.password)} | sudo -S useradd -u 1024 admin",
    "echo ${nonsensitive(var.password)} | sudo -S usermod -g users admin",
    "echo ${nonsensitive(var.password)} | sudo -S passwd admin",
    "docker version",
    "echo ${nonsensitive(var.password)} | sudo -S systemctl enable docker.service",
    "echo ${nonsensitive(var.password)} | sudo -S systemctl enable containerd.service",
    "echo ${nonsensitive(var.password)} | sudo -S systemctl add-wants default.target rpc-statd.service",
    "echo ${nonsensitive(var.password)} | sudo -S systemctl enable rpc-statd",
    "echo ${nonsensitive(var.password)} | sudo -S systemctl start rpc-statd",
    "echo ${nonsensitive(var.password)} | sudo -S systemctl stop ufw",
    "echo ${nonsensitive(var.password)} | sudo -S systemctl disable ufw",
    "echo ${nonsensitive(var.password)} | sudo -S systemctl mask --now ufw",
    "echo ${nonsensitive(var.password)} | sudo -S timedatectl set-ntp yes",
    "echo ${nonsensitive(var.password)} | sudo -S timedatectl set-timezone Australia/Sydney",
     #fix DNS
    "echo ${nonsensitive(var.password)} | sudo -S sed -i 's/#DNS=/DNS=${var.dns_server}/g' /etc/systemd/resolved.conf",
    "echo ${nonsensitive(var.password)} | sudo -S systemctl restart systemd-resolved",
    "rm -rf ${var.homedir}/*",
    "echo ${nonsensitive(var.password)} | sudo -S reboot",
    
    ]
}

}