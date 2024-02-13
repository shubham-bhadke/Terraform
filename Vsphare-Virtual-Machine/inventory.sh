#!/bin/bash
terraform output -json vm_ip_addresses | jq -r 'to_entries[] | "\(.key)    ansible_host=\(.value)       ansible_user=USERNAME"' > ansible_hostname.txt
terraform output -json vm_ip_addresses | jq -r 'to_entries[] | "var_\(.key)_ip=\(.value)"' > var_ip.txt 


input_file_1="ansible_hostname.txt"   # Replace with the path to your first input file
input_file_2="var_ip.txt"   # Replace with the path to your second input file
output_file_path="/hosts"
output_file_name="${1:-$default}"
default="vmwarehosts"
output_file_1="${output_file_path}/${output_file_name}"

# Check if the first input file exists
if [ ! -f "$input_file_1" ]; then
    echo "First input file not found."
    exit 1
fi

# Check if the second input file exists
if [ ! -f "$input_file_2" ]; then
    echo "Second input file not found."
    exit 1
fi

if [ ! -f "$output_file_1" ]; then
    touch "$output_file_1"
fi

# Read content of the first input file into a variable
content_1=$(cat "$input_file_1")

# Read content of the second input file into a variable
content_2=$(cat "$input_file_2")


# Write the content with specified format to the host output file
echo "[all]" > "$output_file_1"
echo "$content_1" >> "$output_file_1"
echo ""
echo "" >> "$output_file_1"
echo "[all:vars]" >> "$output_file_1"
echo "platform=vmware" >> "$output_file_1"
echo "$content_2" >> "$output_file_1"
echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> "$output_file_1"


echo "Ansible files successfully created! "