packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "iso_url" {
  type    = string
  default = "https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
}

variable "iso_checksum" {
  type    = string
  default = "file:https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2.CHECKSUM"
}

variable "accelerator" {
  type    = string
  default = "kvm"
}

source "qemu" "gitlab-runner" {
  iso_url           = var.iso_url
  iso_checksum      = var.iso_checksum
  output_directory  = "output"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  disk_size         = "20G"
  format            = "qcow2"
  accelerator       = var.accelerator
  http_directory    = "."
  ssh_username      = "rocky"
  ssh_password      = "rocky"
  ssh_timeout       = "20m"
  vm_name           = "gitlab-runner-disk.qcow2"
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  boot_wait         = "10s"
  
  # For Cloud images, we usually need to inject user-data to set the password or key
  # Since we don't want to use cloud-init for *runtime* config, strictly speaking,
  # it's okay to use it for *build time* access if we clean it up or if the image requires it.
  # However, with qemu builder and cloud images, we can use cd_files to provide meta-data and user-data.
  cd_files = ["${path.root}/user-data", "${path.root}/meta-data"]
  cd_label = "cidata"
}

build {
  sources = ["source.qemu.gitlab-runner"]

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
    user          = "rocky"
    use_proxy     = false
  }
}
