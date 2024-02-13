########################## This code is for create a resource folder in a vmware inventory ##########################

resource "vsphere_folder" "terraform_folder" {
  path          = "${var.vmfolder}/${var.folder}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

########################## This code is for create a server on vmware ##########################

resource "vsphere_virtual_machine" "vm" {
  for_each               = var.vms
  name                   = each.value.name
  folder                 = resource.vsphere_folder.terraform_folder.path
  resource_pool_id       = data.vsphere_resource_pool.pool.id
  datastore_id           = data.vsphere_datastore.datastore.id
  firmware               = data.vsphere_virtual_machine.template[each.key].firmware
  num_cpus               = lookup(each.value, "cpu", var.vm_vcpu)
  memory                 = lookup(each.value, "memory", var.vm_memory)
  cpu_hot_add_enabled    = var.cpu_hot_add
  cpu_hot_remove_enabled = var.cpu_hot_remove
  memory_hot_add_enabled = var.memory_hot_add
  guest_id               = data.vsphere_virtual_machine.template[each.key].guest_id
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template[each.key].network_interface_types[0]
  }
  disk {
    label            = "disk0"
    unit_number      = 0
    size             = lookup(each.value, "root_vol", var.root_vol_vm)
    eagerly_scrub    = can(data.vsphere_virtual_machine.template[each.key].disks) ? data.vsphere_virtual_machine.template[each.key].disks[0].eagerly_scrub : null
    thin_provisioned = can(data.vsphere_virtual_machine.template[each.key].disks) ? data.vsphere_virtual_machine.template[each.key].disks[0].thin_provisioned : null
  }
  dynamic "disk" {

    for_each = can(each.value.disks) ? each.value.disks : []
    content {
      label            = "data${element(local.additional_disks, disk.key)}"
      size             = disk.value.size
      unit_number      = element(local.additional_disks, disk.key)
      thin_provisioned = var.vm_disk_thin
    }
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template[each.key].id
    /*
    customize {
      linux_options {
        host_name = each.value.name
        domain    = ""
      }
      network_interface {
        ipv4_address = ""
      }
    }
 */
  }
  depends_on = [
    vsphere_folder.terraform_folder
  ]
  tags = [vsphere_tag.owner_tag.id, vsphere_tag.terraform_tag.id ]
}

########################## This code is for create a diks partiion and mount them in a OS ##########################

resource "null_resource" "run_disks_mounting" {


  for_each = {
    for vm_name, vm_config in var.vms : vm_name => vm_config if can(vm_config.disks)
  }

  triggers = {
    vm_name = each.value.name
  }

  # Copy the script to the remote server

  provisioner "file" {
    source      = "diskcreate.sh"      # Update with the path to your script
    destination = "/tmp/diskcreate.sh" # Remote destination path
    connection {
      type     = "ssh"
      user     = var.username
      password = var.password
      host     = resource.vsphere_virtual_machine.vm[each.key].guest_ip_addresses[0]
      timeout  = "1m"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/diskcreate.sh",
      "sudo echo ${join(" ", [for disk in var.vms[each.key].disks : disk.mountpoint])}",
      "sudo bash /tmp/diskcreate.sh ${join(" ", [for disk in var.vms[each.key].disks : disk.mountpoint])}",
      "sudo df -hT"
    ]
    connection {
      type     = "ssh"
      user     = var.username
      password = var.password
      host     = resource.vsphere_virtual_machine.vm[each.key].guest_ip_addresses[0]
      timeout  = "1m"
    }
  }
}

########################## This code is for mount a NFS on a server ##########################

resource "null_resource" "run_nfs_mounting" {
  for_each = { for key, value in var.vms : key => value if length(lookup(value, "nfs", [])) > 0 }

  # Provisioner block to run after the VM is created
  provisioner "remote-exec" {
    inline = flatten([
      # Common configuration for both Linux and Ubuntu
      for nfs in each.value.nfs : [
        "sudo mkdir -p ${nfs.nfs_mount_point}",
        "sudo mount -t nfs ${nfs.nfs_server}:${nfs.nfs_share} ${nfs.nfs_mount_point}",
        "echo '${nfs.nfs_server}:${nfs.nfs_share} ${nfs.nfs_mount_point} nfs defaults 0 0' | sudo tee -a /etc/fstab",
        "sudo df -hT"
      ]
    ])

    connection {
      type     = "ssh"
      user     = var.username
      password = var.password
      host     = resource.vsphere_virtual_machine.vm[each.key].guest_ip_addresses[0]
      timeout  = "1m"
    }
  }
  depends_on = [
    null_resource.run_disks_mounting
  ]
}
