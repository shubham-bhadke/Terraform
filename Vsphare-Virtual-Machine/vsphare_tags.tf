########################## This code is for create a tag category in vmware ##########################

resource "vsphere_tag_category" "managed_category" {
  name        = "Managed_by"
  cardinality = "SINGLE"
  description = "Managed by Terraform"

  associable_types = [
    "VirtualMachine",
    "Datastore",
    "Folder"
  ]
}

resource "vsphere_tag_category" "owner_category" {
  name        = "Owner"
  cardinality = "SINGLE"
  description = "Owner of the resources"

  associable_types = [
    "VirtualMachine",
    "Datastore",
    "Folder"
  ]
}

########################## This code is for create a tag in vmware ##########################

resource "vsphere_tag" "terraform_tag" {
  name        = "Terraform"
  category_id = vsphere_tag_category.managed_category.id
  description = "Managed by Terraform"
}


resource "vsphere_tag" "owner_tag" {
  name        = var.owner
  category_id = vsphere_tag_category.owner_category.id
  description = "Owned by the team"
}
