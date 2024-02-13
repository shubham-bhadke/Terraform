########################################### Login Variables ###########################################
variable "vsphere_user" {
  description = "vsphare login username"
  default     = ""
}

variable "vsphere_password" {
  description = "vsphare login username password"
  default     = ""
}

variable "vsphere_server" {
  description = "VCenter domain name"
  default     = ""
}

########################################### VMware Cluster Variables ###########################################

variable "vmfolder" {
  description = "The path to the folder to put this virtual machine in, relative to the datacenter that the resource pool is in. Path - The absolute path of the folder. For example, given a default datacenter of default-dc, a folder of type vm, and a folder name of terraform-test-folder, the resulting path would be /default-dc/vm/terraform-test-folder."
  default     = ""
}

variable "vmware_compute_cluster" {
  type        = any
  description = "Coumpute Cluster that VM will be deployed, which is define under datacenter/computer cluster."
  default     = ""
}
variable "vmware_resource_pool" {
  type        = any
  description = "Cluster resource pool that VM will be deployed to. you use following to choose default pool in the cluster (esxi1) or (Cluster)/Resources."
  default     = ""
}
variable "vmware_network" {
  type        = any
  description = "Define PortGroup name."
  default     = ""
}
variable "source_image" {
  type        = any
  description = "Name of the template available in the vSphere."
  default     = ""
}
variable "vmware_datacenter" {
  type        = any
  description = "Name of the datacenter you want to deploy the VM to."
  default     = ""
}

variable "vmware_datastore" {
  type        = any
  description = "Datastore to deploy the VM."
  default     = ""
}
########################################### Default Customization Variables ###########################################

variable "vm_disk_thin" {
  description = "Disk type of the created virtual machine , thin or thick"
  default     = "true"
}

variable "cpu_hot_add" {
  description = "Enable : CPU Hotplug Add is a feature that allows the addition of vCPUs to a running virtual machine."
  default     = "true"
}

variable "cpu_hot_remove" {
  description = "Enable : CPU Hotplug remove is a feature that allows the addremove of vCPUs to a running virtual machine."
  default     = "true"
}

variable "memory_hot_add" {
  description = "Enable : Memory Hotplug Add is a feature that allows the addition of vMemory to a running virtual machine."
  default     = "true"
}



########################################### List of VM's Variables ###########################################

variable "vms" {
  type        = any
  description = "List of virtual machines to be deployed"
}

########################################### Customization Compute Variables ###########################################

variable "vm_vcpu" {
  description = "The number of virtual processors to assign to this virtual machine."
  default     = ""
}

variable "vm_memory" {
  description = "The size of the virtual machine's memory in MB"
  default     = ""
}

########################################### Customization Data Disk Variables ###########################################

variable "password" {
  description = "ssh user password to run commands and scripts."
  type        = any
  default     = ""
}

variable "username" {
  description = "server login username"
  type        = any
  default     = ""
}

variable "root_vol_vm" {
  description = "rool volume size of the disk"
  type        = any
  default     = ""
}

variable "folder" {
  type        = string
  description = "The prefix to identify the resources created by the module"
}

variable "owner" {
  type        = string
  description = "Owner name for create a tag. "
}