output "datacenterid" {
  value = data.vsphere_datacenter.dc.id
}

output "vm_ip_addresses" {
  value = {
    for vm_name, vm_config in vsphere_virtual_machine.vm : vm_name => vm_config.guest_ip_addresses[0]
  }
}
