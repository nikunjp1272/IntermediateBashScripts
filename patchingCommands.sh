#!/bin/bash
# Check if the script is run as ec2-user

if [[ $(whoami) != "ec2-user" ]]; then
 echo "This script must be run as ec2-user."
 exit 1
fi
echo "You are running this script as ec2-user."

# Get the total number of installed packages using rpm
rpm_count=$(sudo rpm -qa | wc -l)
echo "Total number of installed packages (using rpm): $rpm_count"

# Get the total number of installed packages using yum
yum_count=$(sudo yum list installed | wc -l)
echo "Total number of installed packages (using yum): $yum_count"

# Get the update information
echo "Yum update info:"
sudo yum updateinfo

# Check the currently used kernel and available kernels
current_kernel=$(sudo uname -r)
echo "Currently running kernel: $current_kernel"
yum check-update | grep kernel
yum list updates kernel
rpm -q kernel

sudo yum update kernel

available_kernels=$(sudo yum list kernel | grep -E '^kernel\.' | awk '{print $2}')
echo "Available kernels:"
echo "$available_kernels"

# Get the OS release information
echo "OS release information:"
cat /etc/*release

# to check a specific lib
dnf check-update | grep packagename
yum check-update packagename
dnf list packagename
dnf list updates packagename
rpm -q packagename
dnf updateinfo list available packagename
dnf info packagename