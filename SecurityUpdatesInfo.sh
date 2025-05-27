#!/bin/bash

# Check if the script is run as ec2-user
if [[ $(whoami) != "ec2-user" || $(whoami) != "nikunj" ]]; then
    echo "This script must be run as ec2-user."
    exit 1
fi

echo "You are running this script as ec2-user."

# Check for rpm and execute commands if it exists
if command -v rpm &> /dev/null; then
    rpm_count=$(sudo rpm -qa | wc -l)
    echo "Total number of installed packages (using rpm): $rpm_count"
fi

# Check for yum and execute commands if it exists
if command -v yum &> /dev/null; then
    yum_count=$(sudo yum list installed | wc -l)
    echo "Total number of installed packages (using yum): $yum_count"

    # Get the update information with timeout
    if ! timeout 30s sudo yum updateinfo; then
        echo "Error: 'yum updateinfo' timed out or failed."
        exit 100
    fi

    echo "Yum update info:"
    sudo yum updateinfo
fi

# Check for dnf and execute commands if it exists
if command -v dnf &> /dev/null; then
    dnf_count=$(sudo dnf list installed | wc -l)
    echo "Total number of installed packages (using dnf): $dnf_count"

    #Get update information with timeout
    if ! timeout 30s sudo dnf updateinfo; then
      echo "Error: 'dnf updateinfo' timed out or failed."
      exit 100
    fi
    echo "dnf update info:"
    sudo dnf updateinfo
fi

# Check for apt and execute commands if it exists
if command -v apt-get &> /dev/null; then
    apt_count=$(sudo apt list --installed | wc -l)
    echo "Total number of installed packages (using apt): $apt_count"

    # Get apt update information with timeout.
    if ! timeout 30s sudo apt update; then
      echo "Error: 'apt update' timed out or failed."
      exit 100
    fi
    echo "apt update info:"
    sudo apt update
fi

# Check the currently used kernel and available kernels
current_kernel=$(sudo uname -r)
echo "Currently running kernel: $current_kernel"

#Check for available kernels based on package manager.
if command -v yum &> /dev/null; then
  available_kernels=$(sudo yum list kernel | grep -E '^kernel\.' | awk '{print $2}')
  echo "Available kernels (yum):"
  echo "$available_kernels"
elif command -v dnf &> /dev/null; then
  available_kernels=$(sudo dnf list kernel | grep -E '^kernel\.' | awk '{print $2}')
  echo "Available kernels (dnf):"
  echo "$available_kernels"
elif command -v apt-get &> /dev/null; then
  available_kernels=$(dpkg -l | grep linux-image | awk '{print $2}')
  echo "Available kernels (apt):"
  echo "$available_kernels"
else
  echo "No supported package manager found to list available kernels."
fi

# Get the OS release information
echo "OS release information:"
cat /etc/*release
