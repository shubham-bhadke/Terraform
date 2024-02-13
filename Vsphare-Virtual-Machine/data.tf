data "vsphere_datacenter" "dc" {
  name = var.vmware_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vmware_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vmware_compute_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vmware_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vmware_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  for_each      = var.vms
  name          = lookup(each.value, "source_image", var.source_image)
  datacenter_id = data.vsphere_datacenter.dc.id
}
