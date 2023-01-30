terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}


provider "libvirt" {
  uri = "qemu+ssh://root@192.168.121.129/system?sshauth=privkey&keyfile=/home/peyman/.ssh/id_rsa"
  
}



# resource "libvirt_pool" "kvm_storage_pool" {

#   name = "default"
#   type = "dir"
#   path = "/var/lib/libvirt/images"

# }


resource "libvirt_volume" "centos7-qcow2" {  
  name = "centos7.qcow2"
  pool = "default"
  source = "http://192.168.121.129/images/centos7.qcow2"
  format = "qcow2"
  
}




# Create a new domain
resource "libvirt_domain" "web1" {
  name = "web-9"
  memory = 2048
  vcpu = 2
  autostart = true
  network_interface {
    network_name = "default" # List networks with virsh net-list
  }

  disk {
    volume_id = libvirt_volume.centos7-qcow2.id 
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

}


output "IPS" {
  value = libvirt_domain.web1.*.network_interface.0.addresses
  
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  pool = "default" # List storage pools using virsh pool-list
  user_data = data.template_file.user_data.rendered
}

  