# 🧩 ROCm 7.1.1 + OpenCL 2.x + PyTorch 2.10.0 (Preview@ROCm7) + Transformers + Docker Setup

[![ROCm](https://img.shields.io/badge/ROCm-7.0.2-ff6b6b?logo=amd)](https://rocm.docs.amd.com/en/docs-7.0.2/about/release-notes.html)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.10.0%20%28nightly%29-ee4c2c?logo=pytorch)](https://pytorch.org/get-started/locally/)
[![Docker](https://img.shields.io/badge/Docker-28.5.1-blue?logo=docker)](https://www.docker.com/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-e95420?logo=ubuntu)](https://ubuntu.com)

## 📌 Overview
This repository provides an **automated installation script** for setting up a complete **AMD ROCm 7.1.1** development environment with:
- **ROCm 7.1.1** GPU drivers + OpenCL 2.x SDK  
- **PyTorch 2.10.0 (Preview@ROCm7)** ROCm build  
- **Transformers 4.57.3** + **Accelerate + Diffusers + Datasets**  
- **Docker environment** with AMD GPU support  
- **Preconfigured GPU test script**

The setup is fully **non-interactive** and optimized for both **desktop** and **server** deployments. In addition it checks whether ROCm or PyTorch (installed via pip) is already present on the system.
If an existing ROCm installation is detected, it removes ROCm and related packages to ensure a clean environment. It also **detects** and **uninstalls** any PyTorch packages (including ROCm-specific builds) to prevent version conflicts before proceeding with a fresh installation.

---

## 🖥️ Supported Platforms

| **Component**      | **Supported Versions**                                |
|---------------------|------------------------------------------------------|
| **OS**            | Ubuntu 22.04.x (Jammy Jellyfish), Ubuntu 24.04.x (Noble Numbat) |
| **Kernels** tested       | 5.15.0-160 (22.04.5) • 6.8.0-88 (24.04.3)                       |
| **GPUs**          | AMD **CDNA2** • **CDNA3** • **RDNA3** • **RDNA4**                 |
| **Docker**        | 29.0.2 (stable)                                       |
| **ROCm**          | 7.1.1                                                |
| **PyTorch**       | torch 2.10.0.dev20251027+rocm7.0, torchvision 0.25.0.dev20251028+rocm7.0                            |
| **Transformers**  | 4.57.3                                               |

**⚠️ Note**: **Ubuntu 20.04.x (Focal Fossa)** is **not supported**. The last compatible ROCm version for 20.04 is **6.4.0**.

---

## ⚡ Features
- Automated **ROCm GPU drivers + HIP + OpenCL SDK** installation
- **PyTorch ROCm nightly** with GPU acceleration
- Preinstalled **Transformers**, **Accelerate**, **Diffusers**, and **Datasets**
- Integrated **Docker environment** with ROCm GPU passthrough
- **vLLM Docker images** for **RDNA4** & **CDNA3**
- Optimized for **AI workloads**, **LLM inference**, and **model fine-tuning**

---

## 🚀 Installation

### 1️⃣ **System preperation**
Install **Ubuntu 22.04.5 LTS** or **Ubuntu 24.04.3 LTS** (Server or Desktop version).

**Recommendations:**
- Use a fresh Ubuntu installation if possible
- Assign the full storage capacity during installation
- Install **OpenSSH** for remote SSH management
- The script automatically checks the system for installed versions of ROCm, PyTorch, and Docker, and removes them if found
  - On a fresh Ubuntu installation, the script automatically skips the deinstallation routine, as illustrated below
    <img width="697" height="188" alt="{DB29AEE6-CF12-4D0D-BA9F-611E73DBE146}" src="https://github.com/user-attachments/assets/48516cb6-e7bd-4c7e-94bb-f3ec9a95b243" />
  - If an existing version is detected, it will be deleted, regardless of whether it is the same or an older release.
    <img width="724" height="312" alt="{ABC66E35-246B-49CD-B988-5C19DA511ACB}" src="https://github.com/user-attachments/assets/c0a87932-fb0e-4adb-8bf9-cbe80d13f528" />
- SBIOS settings:
  - When using Linux, you should disable Secure Boot
  - On WRX80 and WRX90 motherboard solutions, make sure SR-IOV is enabled — there are known issues with Ubuntu Linux detecting the network otherwise

### 2️⃣ **Download the Script from the Repository**
```bash
wget https://raw.githubusercontent.com/JoergR75/rocm-7.1.1-pytorch-2.10.0-docker-cdna3-rdna4-automated-deployment/refs/heads/main/script_module_ROCm_711_Ubuntu_22.04-24.04_pytorch_2.10.0_server.sh
```

<img width="900" height="274" alt="{84453C90-219D-481A-AB83-8FFD8C9922CB}" src="https://github.com/user-attachments/assets/31a42935-15ba-460f-9658-85f19a21c45a" />

### 3️⃣ **Run the Installer**
```bash
bash script_module_ROCm_702_Ubuntu_22.04-24.04_pytorch_2.10.0_server.sh
```
**⚠️ Note**: Entering the user password may be required.

<img width="800" height="508" alt="{80D0F6B6-D2F2-4693-9CC7-D727C649BE40}" src="https://github.com/user-attachments/assets/24c29e5c-ec1b-494b-bc3d-6bc7e96313bd" />

The installation takes ~15 minutes depending on internet speed and hardware performance.

### 4️⃣ **Reboot the System**
After the successful installation, press "y" to reboot the system and activate all installed components.

<img width="802" height="494" alt="{CD8E3669-C448-420D-B9A8-1EC4247616C8}" src="https://github.com/user-attachments/assets/9fde1927-5f25-45eb-9cb6-ef02ee1fe21e" />

## 🧪 Testing ROCm + PyTorch

After rebooting, verify your setup:

This script creates a simple diagnostic python file (test.py) to verify that PyTorch with ROCm support is correctly installed and working.

What it does:

- Shows the CPU and installed memory
- Prints the PyTorch version and ROCm version.
- Checks if ROCm is available and how many GPUs are detected.
- Displays the name of the first GPU (if available).
- Creates two random 3×3 tensors directly on the GPU (if available).
- Performs a simple tensor addition operation on the GPU.
- Prints confirmation that the operation was successful and shows the result.

Example usage:
```bash
python3 test.py
```
Expected Output Example:

<img width="779" height="294" alt="{2BFF554C-D825-4E01-9B18-8CA52A59D97F}" src="https://github.com/user-attachments/assets/9bfdb5bb-40c2-4305-b66a-902efcd6c8c8" />

## 📶 ROCm Bandwidth Test

**AMD’s ROCm Bandwidth Test utility** with the **`-a` (all tests)** flag runs a complete set of bandwidth diagnostics.

### What it does

`rocm-bandwidth-test` is a diagnostic tool included in ROCm that measures **memory bandwidth performance** between:

- Host (CPU) ↔ GPU(s)  
- GPU ↔ GPU (if multiple GPUs are installed)  
- GPU internal memory  

### `-a` (all tests) option

Using the `-a` flag runs **all available tests**, including:

- **Host-to-Device (H2D)** bandwidth  
- **Device-to-Host (D2H)** bandwidth  
- **Device-to-Device (D2D)** bandwidth (for multi-GPU)  
- **Bidirectional / concurrent** bandwidth tests  

Run the P2P test
```bash
sudo /opt/rocm/bin/rocm-bandwidth-test -a
```

### Output

The tool prints results in a **matrix format** showing bandwidth (GB/s) between every device pair.

<img width="646" height="663" alt="{51926F23-C527-4447-89E4-69A64A4CB02C}" src="https://github.com/user-attachments/assets/1799223f-a123-41e9-9f87-d4ddf5f9266a" />

⚠️ **Caution:**  
Make sure **"Resize BAR"** is enabled in the **SBIOS**.  
If it is disabled, **P2P** will be deactivated, as shown below:

<img width="634" height="654" alt="{C8894609-B944-443A-9A1B-D183F18E9C28}" src="https://github.com/user-attachments/assets/de3ab31b-6946-4770-8798-a9e820ce0c1b" />

### ⚙️ How to Enable **Resize BAR** in SBIOS

1. Enter **SBIOS**  
2. Navigate to **Advanced**  
3. Go to **PCI Subsystem Settings**

<img width="357" height="203" alt="image" src="https://github.com/user-attachments/assets/0f1d7c5f-5433-4c5e-afd8-72158c603482" />
=>
<img width="492" height="150" alt="image" src="https://github.com/user-attachments/assets/4261936a-d983-481a-8129-9f9bd1f8a0a4" />

## 🐋 Docker Integration

The script sets up a Docker environment with GPU passthrough support via ROCm.

Check Docker Installation
```bash
docker --version
```
<img width="681" height="63" alt="{402A8436-9377-42B3-B1A9-EEEF02B21C7B}" src="https://github.com/user-attachments/assets/9a0ffaa2-5236-4a7d-86bb-be2c50a5925a" />

### 🤖 vLLM Docker Images

To use vLLM optimized for RDNA4 and CDNA3:
Use the container image you need.
```bash
# RDNA4 build
sudo docker pull rocm/vllm-dev:open-r9700-08052025
```
or
```bash
# CDNA3 build
sudo docker pull rocm/vllm:latest
```

Run vLLM with all available AMD GPU Access (example for RDNA4)
```bash
sudo docker run -it \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    --group-add video \
    rocm/vllm-dev:open-r9700-08052025
```
With `rocm-smi`, you can verify all available GPUs (in this case, 2× Radeon AI PRO R9700 GPUs).

<img width="929" height="199" alt="{F715178C-A958-4529-9BB3-9F2E2F7661A2}" src="https://github.com/user-attachments/assets/46094f88-5540-453d-829e-f2ec07b3ad95" />

If you need to add a specific GPU, you can use the **passthrough** option.  
First, verify the available GPUs in the `/dev/dri` directory.

<img width="381" height="64" alt="{CA7F5FFD-B028-4620-B625-A0FCDA00155D}" src="https://github.com/user-attachments/assets/b976b314-f885-4373-8452-be52a8a05244" />

Let's choose **GPU2**, also referred to as **"card2"** or **"renderD129"**.
```bash
sudo docker run -it \
    --device=/dev/kfd \
    --device=/dev/dri/card2 \
    --device=/dev/dri/renderD129 \
    --security-opt seccomp=unconfined \
    --group-add video \
    rocm/vllm-dev:open-r9700-08052025
```
GPU2 has been added to the container

<img width="933" height="305" alt="{988A3311-56B1-4BDB-95A6-DF00A4D2BE6D}" src="https://github.com/user-attachments/assets/b630ad80-b163-453a-be29-b03c346aae8b" />
