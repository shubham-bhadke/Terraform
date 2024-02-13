#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Specify the base volume group name, base logical volume name, and mount directories
base_volume_group_name="centos-vg"
base_logical_volume_name="centos-lv"
base_mount_dirs=("${@:-${default[@]}}")
default=(data1 data2)
disks_mounts=()

# Discover available free disks (excluding those already part of a physical volume)
available_disks=($(lsblk -n -d -o NAME -p | grep -E 'sd[b-z]'))

# Check if there are enough disks
if [ ${#available_disks[@]} -lt 2 ]; then
    echo "Not enough available disks for the script. Exiting."
    exit 1
fi

# Filter out disks that are already part of a physical volume
filtered_disks=()
for disk in "${available_disks[@]}"; do
    if ! pvdisplay "$disk" &> /dev/null; then
        filtered_disks+=("$disk")
    else
        echo "Disk $disk is already part of a physical volume. Skipping."
    fi
done

# Check if there are enough filtered disks
if [ ${#filtered_disks[@]} -lt 2 ]; then
    echo "Not enough available and free disks for the script. Exiting."
    exit 1
fi

# Create physical volumes from available free disks
pvcreate "${filtered_disks[@]}"

# Iterate over the filtered disks and create a volume group and logical volume for each
for ((i=0; i<${#filtered_disks[@]}; i++)); do
    disk="${filtered_disks[i]}"

    # Extract the last name of each disk and use it in the volume group and logical volume names
    last_name=$(echo "$disk" | awk -F '/' '{print $NF}' | tr -cd '[:alnum:]')
    volume_group_name="${base_volume_group_name}-${last_name}"
    logical_volume_name="${base_logical_volume_name}-${last_name}"

    # Create a volume group from the physical volumes
    vgcreate $volume_group_name "$disk"

    # Create a logical volume from the volume group
    lvcreate -n $logical_volume_name -l 100%FREE $volume_group_name

    # Format the logical volume with XFS file system
    mkfs.xfs /dev/$volume_group_name/$logical_volume_name

    # Create the mount directory using the current base_mount_dir value
    mount_dir="${base_mount_dirs[i]}"
    disks_mounts+=("$mount_dir")

    # Create the mount directory if it doesn't exist
    mkdir -p "/$mount_dir"

    # Mount the logical volume to the specified directory
    mount "/dev/$volume_group_name/$logical_volume_name" "/$mount_dir"

    echo "Mounted /dev/$volume_group_name/$logical_volume_name to /$mount_dir"

    # Update /etc/fstab for permanent mounting
    echo "/dev/$volume_group_name/$logical_volume_name /$mount_dir xfs defaults 0 0" >> /etc/fstab
done

echo "Updated /etc/fstab for permanent mounting."
