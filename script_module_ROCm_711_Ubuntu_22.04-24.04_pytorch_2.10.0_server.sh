#!/bin/bash
# ================================================================================================================
# ROCm 7.1.1 + OpenCL 2.x + PyTorch 2.10.0 (nightly for ROCm7.1) + Transformers + Docker Setup
# Compatible with Ubuntu 22.04.x and 24.04.x (Desktop & Server) — Ubuntu 20.04.x is no longer supported
# ================================================================================================================
# Description:
# This script automates the installation of AMD ROCm 7.1.1, PyTorch 2.10.0 (nightly for ROCm7.1), Transformers, and Docker
# on Ubuntu 22.04.x and 24.04.x systems. It automatically fetches the appropriate installation scripts and performs
# a fully non-interactive setup optimized for both desktop and server environments.
# ================================================================================================================
#
# REQUIREMENTS:
# ---------------------------------------------------------------------------------------------------------------
# Operating System (OS):
#   - Ubuntu 22.04.5 LTS (Jammy Jellyfish)
#   - Ubuntu 24.04.3 LTS (Noble Numbat)
#
# Kernel Versions Tested:
#   - Ubuntu 22.04.5: 5.15.0-160
#   - Ubuntu 24.04.3: 6.8.0-88
#
# Supported Hardware:
#   - AMD CDNA2 | CDNA3 | RDNA3 | RDNA4 GPU Architectures | Strix APU
#
# SOFTWARE VERSIONS:
# ---------------------------------------------------------------------------------------------------------------
# ROCm Platform:         7.1.1
# ROCm Release Notes:    https://rocm.docs.amd.com/en/docs-7.1.1/about/release-notes.html
# ROCm Driver Repo:      https://repo.radeon.com/amdgpu-install/7.1.1/ubuntu/
#
# PyTorch:               2.10.0.dev20251123+rocm7.0
# Transformers:          4.57.3
# Docker:                min. 28.5.0 (the script will verify and skip installation if minimum requirements are installed)
#
# INCLUDED TOOLS:
# ---------------------------------------------------------------------------------------------------------------
#   - git                 → Version control system for tracking changes
#   - git-lfs             → Git Large File Storage for handling large datasets & binaries
#   - cmake               → Cross-platform build system for compiling and packaging software
#   - htop                → Interactive process monitoring tool
#   - ncdu                → NCurses Disk Usage analyzer for efficient storage management
#   - libmsgpack-dev      → Development package for MessagePack (binary serialization format)
#   - freeipmi-tools      → Utilities for querying BMC firmware versions and IPMI functions
#   - rocm-bandwidth-test → Utility to measure and validate host↔GPU and inter-GPU memory bandwidth
#
# EXECUTION DETAILS:
# ---------------------------------------------------------------------------------------------------------------
# Author:                Joerg Roskowetz
# Estimated Runtime:     ~15 minutes (depending on system performance and internet speed)
# Last Updated:          December 12th, 2025
# ================================================================================================================

# global stdout method
function print () {
    printf "\033[1;36m\t$1\033[1;35m\n"; sleep 4
}

clear &&
print '\n🚀 ROCm 7.1.1 + OpenCL 2.x + PyTorch 2.10.0 (nightly for ROCm7.1) + Transformers + Docker Setup\nCompatible with Ubuntu 22.04.x and 24.04.x (Desktop & Server)\n⚠️ Ubuntu 20.04.x is no longer supported\n'
print '\nUbuntu OS Update ...\n'

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

print '\nDone\n'

install_focal() {
    print '\nUbuntu 20.04.x (focal) is not longer be supported for ROCm 7.1.1 The last supported version is ROCm 6.4.0.\n'
    print 'More details can be verified under https://repo.radeon.com/amdgpu-install/6.4/ubuntu/ \n'
}

install_jellyfish() {
    print '\nUbuntu 22.04.x (jammy jellyfish) installation method has been set.\n'
    print '\nChecking if ROCm is installed ...\n'

    if dpkg -l | grep -q rocm; then
        print '\nROCm detected. Removing ROCm and associated packages ...\n'

        sudo apt autoremove -yq rocm-core
        sudo apt autoremove -yq amdgpu-dkms
        sudo rm -rf /var/cache/apt/*
        sudo apt-get clean all -yq

        print '\nROCm packages removed successfully.'
    else
        print 'No ROCm installation detected.'
    fi

    print '\nChecking for PyTorch packages installed via pip ...\n'

    # Use pip with --break-system-packages to avoid "externally-managed-environment" error
    if python3 -m pip list | grep torch; then
        python3 -m pip uninstall -y torch torchvision torchaudio pytorch-triton-rocm
        printf "\nPyTorch packages uninstalled successfully.\n"
    else
        printf "\nNo PyTorch packages found.\n"
    fi

    # Pause before continuing
    read -n1 -r -p "Press any key to continue..." key

    # Download the installer script
    wget https://repo.radeon.com/amdgpu-install/7.1.1/ubuntu/jammy/amdgpu-install_7.1.1.70101-1_all.deb
    # install latest headers and static library files necessary for building C++ programs which use libstdc++
    sudo DEBIAN_FRONTEND=noninteractive apt-get install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)" -yq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install python3-setuptools python3-wheel libpython3.10 -yq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install libstdc++-12-dev -yq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install git-lfs -yq

    # Install with "default" settings (no interaction)
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq ./amdgpu-install_7.1.1.70101-1_all.deb --allow-downgrades

    # Installing multiple use cases including ROCm 7.1.1, OCL and HIP SDK

    print '\nInstalling ROCm 7.1.1 + OCL 2.x environment ...\n'

    sudo DEBIAN_FRONTEND=noninteractive apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq amdgpu-dkms rocm

    # Groups setup and ROCm/OCL path in global *.icd file
    # Add path into global amdocl64*.icd file

    echo "/opt/rocm/lib/libamdocl64.so" | sudo tee /etc/OpenCL/vendors/amdocl64*.icd

    # add the user to the sudo group (iportant e.g. to compile vllm, flashattention in a pip environment)

    sudo usermod -a -G video,render ${SUDO_USER:-$USER}
    sudo usermod -aG sudo ${SUDO_USER:-$USER}

    # Install tools - git, htop, cmake, libmsgpack-dev, ncdu (NCurses Disk Usage utility / df -h) and freeipmi-tools (BMC version read)

    source ~/.bashrc
    sudo DEBIAN_FRONTEND=noninteractive apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq git
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq htop
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq freeipmi-tools
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq ncdu
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq cmake
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq libmsgpack-dev
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq rocm-bandwidth-test

    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc

    print '\nInstalling Pytorch 2.10.0 (nightly for ROCm7), Transformers environment ...\n'

    python3 -m pip install --upgrade pip --quiet --no-input
    python3 -m pip install --upgrade pip wheel --quiet --no-input
    python3 -m pip install joblib --quiet --no-input
    python3 -m pip install setuptools_scm --quiet --no-input
    python3 -m pip install --pre torch torchvision --index-url https://download.pytorch.org/whl/nightly/rocm7.1 --no-input
    python3 -m pip install transformers --quiet --no-input
    python3 -m pip install accelerate --quiet --no-input
    python3 -m pip install -U diffusers --quiet --no-input
    python3 -m pip install protobuf --quiet --no-input
    python3 -m pip install sentencepiece --quiet --no-input 
    python3 -m pip install datasets --quiet --no-input
}

install_noble() {
    print '\nUbuntu 24.04.x (noble numbat) installation method has been set.\n'
    print '\nChecking if ROCm is installed ...\n'

    if dpkg -l | grep -q rocm; then
        print '\nROCm detected. Removing ROCm and associated packages ...\n'

        sudo apt autoremove -y rocm-core
        sudo apt autoremove -y amdgpu-dkms
        sudo rm -rf /var/cache/apt/*
        sudo apt-get clean all

        print '\nROCm packages removed successfully.'
    else
        print 'No ROCm installation detected.'
    fi

    print '\nChecking for PyTorch packages installed via pip ...\n'

    # Use pip with --break-system-packages to avoid "externally-managed-environment" error
    if python3 -m pip list | grep torch; then
        python3 -m pip uninstall -y torch torchvision torchaudio pytorch-triton-rocm --break-system-packages
        printf "\nPyTorch packages uninstalled successfully.\n"
    else
        printf "\nNo PyTorch packages found.\n"
    fi

    # Pause before continuing
    read -n1 -r -p "Press any key to continue..." key

    # Download the installer script
    wget https://repo.radeon.com/amdgpu-install/7.1.1/ubuntu/noble/amdgpu-install_7.1.1.70101-1_all.deb
    # Install the necessary headers and static library files
    sudo DEBIAN_FRONTEND=noninteractive apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)" --yes
    sudo DEBIAN_FRONTEND=noninteractive apt install python3-setuptools python3-wheel libpython3.12 --yes
    sudo DEBIAN_FRONTEND=noninteractive apt install libstdc++-13-dev --yes
    sudo DEBIAN_FRONTEND=noninteractive apt install git-lfs --yes

    # Install with "default" settings (no interaction)
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq ./amdgpu-install_7.1.1.70101-1_all.deb --allow-downgrades

    # Installing multiple use cases including ROCm 7.1.1, OCL and HIP SDK

    print '\nInstalling ROCm 7.1.1 + OCL 2.x environment ...\n'

    sudo apt update
    sudo apt install amdgpu-dkms rocm --yes

    # Groups setup and ROCm/OCL path in global *.icd file
    # Add path into global amdocl64*.icd file

    echo "/opt/rocm/lib/libamdocl64.so" | sudo tee /etc/OpenCL/vendors/amdocl64*.icd

    # add the user to the sudo group (iportant e.g. to compile vllm, flashattention in a pip environment)

    sudo usermod -a -G video,render ${SUDO_USER:-$USER}
    sudo usermod -aG sudo ${SUDO_USER:-$USER}

    # Install tools - git, htop, cmake, libmsgpack-dev, ncdu (NCurses Disk Usage utility / df -h) and freeipmi-tools (BMC version read)

    source ~/.bashrc
    sudo DEBIAN_FRONTEND=noninteractive apt install -y git
    sudo DEBIAN_FRONTEND=noninteractive apt install -y htop
    sudo DEBIAN_FRONTEND=noninteractive apt install -y freeipmi-tools
    sudo DEBIAN_FRONTEND=noninteractive apt install -y ncdu
    sudo DEBIAN_FRONTEND=noninteractive apt install -y cmake
    sudo DEBIAN_FRONTEND=noninteractive apt install -y libmsgpack-dev
    sudo DEBIAN_FRONTEND=noninteractive apt install -y rocm-bandwidth-test

    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc

    print '\nInstalling Pytorch 2.10.0 (nightly for ROCm7), Transformers environment ...\n'

    pip3 install --upgrade pip --break-system-packages
    pip3 install --upgrade pip wheel --break-system-packages
    pip3 install joblib --break-system-packages
    pip3 install setuptools_scm --break-system-packages
    pip3 install --pre torch torchvision --index-url https://download.pytorch.org/whl/nightly/rocm7.1 --no-input --break-system-packages
    pip3 install transformers --break-system-packages
    pip3 install accelerate --break-system-packages
    pip3 install -U diffusers --break-system-packages
    pip3 install protobuf --break-system-packages
    pip3 install sentencepiece --break-system-packages
    pip3 install datasets --break-system-packages
}

# Check if supported Ubuntu release exists
if command -v lsb_release > /dev/null; then
    UBUNTU_CODENAME=$(lsb_release -c -s)

    if [ "$UBUNTU_CODENAME" = "focal" ]; then
        print '\nDetected Ubuntu Focal Fossa (20.04.x).\n'

install_focal

    elif [ "$UBUNTU_CODENAME" = "jammy" ]; then
        print '\nDetected Ubuntu Jammy Jellyfish (22.04.x).\n'

install_jellyfish

 elif [ "$UBUNTU_CODENAME" = "noble" ]; then
        print '\nDetected Ubuntu Noble Numbat (24.04.x).\n'

install_noble

    else
        print '\nUnknown Ubuntu version!\n'
    fi
else
    print '\nlsb_release command not found. Unable to determine Ubuntu version.\n'
fi

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# create test script
cd ~
cat <<EOF > test.py
#!/usr/bin/env python3

import torch
import subprocess
import re
import os

def get_cpu_model():
    with open("/proc/cpuinfo") as f:
        for line in f:
            if "model name" in line:
                return line.split(":")[1].strip()

print("\nInstalled CPU:", get_cpu_model())

def get_total_memory_gb():
    with open("/proc/meminfo") as f:
        for line in f:
            if line.startswith("MemTotal:"):
                # Extract the numeric value in kB
                mem_kb = int(re.findall(r'\d+', line)[0])
                # Convert to GB (1 GB = 1024^2 kB)
                mem_gb = mem_kb / (1024 ** 2)
                return f"Total System-Memory: {mem_gb:.0f} GB"

if __name__ == "__main__":
    print(get_total_memory_gb())

print("PyTorch version:", torch.__version__)
print("ROCm version:", subprocess.getoutput("/opt/rocm/bin/hipconfig --version"))
print("Is ROCm available:", torch.version.hip is not None)
print("Number of GPUs:", torch.cuda.device_count())
print("\nGPU Name:", torch.cuda.get_device_name(0) if torch.cuda.device_count() > 0 else "No GPU detected")

# Create two tensors and add them on the GPU
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

a = torch.rand(3, 3, device=device)
b = torch.rand(3, 3, device=device)
c = a + b

print("\nTensor operation successful on:", device)
print(c)
EOF

set -e
MIN_DOCKER_VERSION="25.0.0"

# Function to compare Docker versions
version_ge() {
    [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

# --- Function: install_docker -------------------------------------------------
install_docker() {
    echo -e "\nInstalling and configuring Docker (stable version) with required dependencies..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo DEBIAN_FRONTEND=noninteractive apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq docker-ce docker-ce-cli containerd.io
    sudo usermod -a -G docker ${SUDO_USER:-$USER}
    sudo service docker restart
    docker --version
    echo -e "\n✅ Docker installation completed."
}

# --- Docker version check -----------------------------------------------------
if command -v docker &> /dev/null; then
    INSTALLED_DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    echo "Detected Docker version: ${INSTALLED_DOCKER_VERSION}"
    if version_ge "$INSTALLED_DOCKER_VERSION" "$MIN_DOCKER_VERSION"; then
        echo "Docker ${INSTALLED_DOCKER_VERSION} meets minimum version (${MIN_DOCKER_VERSION}). Skipping installation."
    else
        echo "Docker version below ${MIN_DOCKER_VERSION}, updating..."
        install_docker
    fi
else
    echo "Docker not found. Installing..."
    install_docker
fi

# Final installation message
print '\n✅ Finished ROCm 7.1.1 + OCL 2.x + PyTorch 2.10.0 (nightly for ROCm7.1) + Transformers environment installation and setup.\n'

# Post-reboot testing instructions
printf "\nAfter the reboot, test your installation with:\n"
printf "  • rocminfo\n"
printf "  • clinfo\n"
printf "  • rocm-smi\n"
printf "  • amd-smi\n"
printf "  • rocm-bandwidth-tool\n"

# PyTorch verification
printf "\nVerify the active PyTorch device:\n"
printf "  python3 test.py\n"

# vLLM Docker images for RDNA4 and CDNA3
printf "\nInstall the latest vLLM Docker images:\n"
printf "  RDNA4 → sudo docker pull rocm/vllm-dev:rocm7.1.1_navi_ubuntu24.04_py3.12_pytorch_2.8_vllm_0.10.2rc1\n"
printf "  CDNA3 → sudo docker pull rocm/vllm:latest\n"

# Run the Docker container
printf "\nStart the vLLM Docker container:\n"
printf "  sudo docker run -it --device=/dev/kfd --device=/dev/dri \\
    --security-opt seccomp=unconfined --group-add video rocm/vllm-dev:rocm7.1.1_navi_ubuntu24.04_py3.12_pytorch_2.8_vllm_0.10.2rc1\n"

printf "\nThe container will run using the image 'rocm/vllm-dev:rocm7.1.1_navi_ubuntu24.04_py3.12_pytorch_2.8_vllm_0.10.2rc1', with flags enabling AMD GPU access via ROCm.\n\n"

# reboot option
print 'Reboot system now (recommended)? (y/n)'
read q
if [ $q == "y" ]; then
    for i in 3 2 1
    do
        printf "Reboot in $i ...\r"; sleep 1
    done
    sudo reboot
fi
