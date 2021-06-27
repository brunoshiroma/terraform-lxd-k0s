terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "1.5.0"
    }
  }
}

provider "lxd" {
  # Configuration options
}

resource "lxd_storage_pool" "k0s-pool" {
  name   = "k0s-pool"
  driver = "dir"
}

resource "lxd_volume" "k0s-volume" {
  name = "k0s-volume"
  pool = lxd_storage_pool.k0s-pool.name
}

resource "lxd_network" "k0s-network" {
  name = "k0s-network"
  config = {
    "ipv4.address" = "10.150.19.1/24"
    "ipv4.nat"     = "true"
  }
}

resource "lxd_profile" "k0s-profile" {
  name = "k0s-profile"

  device {
    name = "eth0"
    type = "nic"

    properties = {
      nictype = "bridged"
      parent  = "${lxd_network.k0s-network.name}"
    }
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      pool = "${lxd_storage_pool.k0s-pool.name}"
      path = "/"
    }
  }
}



resource "lxd_container" "k0s-001" {
  name      = "k0s-001"
  image     = "ubuntu:20.04"
  ephemeral = false

  config = {
    "linux.kernel_modules" = "ip_tables,ip6_tables,netlink_diag,nf_nat,overlay"
    "boot.autostart"       = true
    "security.privileged"  = "true"
    "raw.lxc"              = "lxc.apparmor.profile=unconfined\nlxc.cap.drop= \nlxc.cgroup.devices.allow=a\nlxc.mount.auto=proc:rw"
    "security.privileged"  = "true"
    "security.nesting"     = "true"
  }

  limits = {
    cpu = 2
  }

  profiles = ["${lxd_profile.k0s-profile.name}"]

  provisioner "local-exec" {
    command = <<EXEC
lxc exec ${self.name} -- bash -xe -c '
curl -sSLf https://get.k0s.sh | sudo sh && k0s install controller --enable-worker && systemctl start k0scontroller.service && systemctl enable k0scontroller.service
'
EXEC
  }

  provisioner "local-exec" {
    command = <<EXEC
lxc exec ${self.name} -- bash -xe -c '
echo "L /dev/kmsg - - - - /dev/console" > /etc/tmpfiles.d/kmsg.conf
'
EXEC
  }

  provisioner "local-exec" {
    command = <<EXEC
lxc exec ${self.name} -- bash -xe -c '
reboot
'
EXEC
  }

  //provisioner "local-exec" {
  //  command = "lxc file pull k0s-001/var/lib/k0s/pki/admin.conf lxd-k0s.conf"
  //}

}