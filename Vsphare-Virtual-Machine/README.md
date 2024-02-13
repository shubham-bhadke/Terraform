# Create an VMware(vsphare) virtual machines with Terraform

This demo is intended to demonstrate how to create virtual machines on vmware(vsphare) using Terraform, with multiple disks and nfs mount.

# Implementation

## Pre-requisites

This code is split into two parts,

1. Infrastructure for Codepipeline Deployment. ie, code under the path ```Vsphare-Virtual-Machine/```

To achieve this, follow the pre-requisites steps below

1. Install Terraform : [link](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. Create a S3 Bucket in us-east-1. This bucket will be used to store the terraform state file. Note the bucket arn as it will be used in the steps below.

## Folder Structure for Infrastructure provision

```
.
├── README
├── README.md
├── backend.tf
├── data.tf
├── diskcreate.sh
├── inventory.sh
├── locals.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── terra.conf
├── terraform.tfvars
├── variables.tf
└── vsphare_tags.tf
```

## Provision Infrastructure

Deploying the Infrastructure:

1. Navigate to the directory `cd provision-vmware-infra/` 
2. Open the file `terraform.tfvars` and change the the variable values as per your requirments. Example file below,
```
vsphere_user     = ""
vsphere_password = ""
vsphere_server = ""

vms = {
  master1 = {
    name         = "terraform-master1"
    cpu          = "10"
    memory       = "10096"
    root_vol     = "300"
    source_image = "TEMPLATE_name"
    disks = [
      {
        size       = "120"
        mountpoint = "/data1"
      },
      {
        size       = "140"
        mountpoint = "/data2"
      }
    ]
    nfs = [
      {
        nfs_server      = "SERVER_IP"
        nfs_share       = "/nfs_share"
        nfs_mount_point = "/mount"
      },
      {
        nfs_server      = "SERVER_IP"
        nfs_share       = "/nfs_backups"
        nfs_mount_point = "/backup"
      }
    ] 
  },
    master2 = {
    name         = "terraform-master2"
    cpu          = "10"
    memory       = "10096"
    root_vol     = "300"
    source_image = "TEMPLATE_name"
    disks = [
      {
        size       = "100"
        mountpoint = "/data1"
      },
      {
        size       = "100"
        mountpoint = "/data2"
      }
    ]
    nfs = [
      {
        nfs_server      = "SERVER_IP"
        nfs_share       = "/nfs_share"
        nfs_mount_point = "/mount"
      },
      {
        nfs_server      = "SERVER_IP"
        nfs_share       = "/nfs_backups"
        nfs_mount_point = "/backup"
      }
    ] 
  }
}
```
3. Change the BUCKET_NAME in the file `Vsphare-Virtual-Machine/backend.tf` with the bucket you created in pre-requisites. Use the bucket name, not the ARN


You are all set. Let's run the code

1. Navigate to the directory `cd Vsphare-Virtual-Machine` 
2. Run `terraform init`
3. Run `terraform validate`
4. Run `terraform plan`  and review the output in `terminal`
5. Run `terraform apply` and review the output in `terminal` and when ready, type `yes` and hit enter

We have two scripts as below. 

1. diskcreate.sh  - This script helps to create a multiple disks and mount them at a specific mount path, The following structure help to create and mount disks.

```
    disks = [
      {
        size       = "100"
        mountpoint = "/data1"
      },
      {
        size       = "100"
        mountpoint = "/data2"
      }
    ]
```

2. inventory.sh  - This script helps to create a dynamic hosts file of newly created servers, with the help of this file we can push any application configuration.


Reference links:

1. Terraform Provider for VMware vSphere: <https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs>

