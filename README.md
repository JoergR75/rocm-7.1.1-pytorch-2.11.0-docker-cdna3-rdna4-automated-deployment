# 🧩 ROCm 7.1.1 + OpenCL 2.x + PyTorch 2.10.0 (Preview@ROCm7.1) + Transformers + Docker Setup

[![ROCm](https://img.shields.io/badge/ROCm-7.1.1-ff6b6b?logo=amd)](https://rocm.docs.amd.com/en/docs-7.1.1/about/release-notes.html)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.10.0%20%28nightly%29-ee4c2c?logo=pytorch)](https://pytorch.org/get-started/locally/)
[![Docker](https://img.shields.io/badge/Docker-29.1.0-blue?logo=docker)](https://www.docker.com/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-e95420?logo=ubuntu)](https://ubuntu.com)

## 📌 Overview
This repository provides an **automated installation script** for setting up a complete **AMD ROCm 7.1.1** development environment with:
- **ROCm 7.1.1** GPU drivers + OpenCL 2.x SDK  
- **PyTorch 2.10.0 (Preview@ROCm7.1)** ROCm build  
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
| **GPUs**          | AMD **CDNA2** • **CDNA3** • **RDNA3** • **RDNA4** • **Strix APU**                 |
| **Docker**        | 29.1.0 (stable)                                       |
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
bash script_module_ROCm_711_Ubuntu_22.04-24.04_pytorch_2.10.0_server.sh
```
**⚠️ Note**: Entering the user password may be required.

<img width="908" height="418" alt="{FC933549-11D1-4CF2-8FD6-2A683E038546}" src="https://github.com/user-attachments/assets/fa2abca8-8441-42d0-ab9a-aab15bf14c07" />

The installation takes ~15 minutes depending on internet speed and hardware performance.

### 4️⃣ **Reboot the System**
After the successful installation, press "y" to reboot the system and activate all installed components.

<img width="901" height="562" alt="{01FB8878-B0B9-4DEB-B1E4-F6315E3D0D5F}" src="https://github.com/user-attachments/assets/f34408c0-1738-4941-ba95-a68b95558d70" />

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

<img width="883" height="292" alt="{06D61B7B-36D4-4611-838E-36D1D9A1D2C1}" src="https://github.com/user-attachments/assets/b9f75b18-e1c3-416f-85e1-336be812cf87" />

More details about the ROCm driver version can be reviewed:
```bash
apt show rocm-libs -a
```

<img width="898" height="527" alt="{8CE38CD7-EA93-44A4-8778-C1EE06F19243}" src="https://github.com/user-attachments/assets/5396ce18-93d4-40cf-9025-173d8c04d4fe" />

## 🐋 Docker Integration

The script sets up a Docker environment with GPU passthrough support via ROCm.

Check Docker Installation
```bash
docker --version
```
<img width="896" height="62" alt="{A01686FA-B579-4D64-91BB-147D5A2563F3}" src="https://github.com/user-attachments/assets/3f24a8c1-7a1d-435f-94a4-de8a9b9d3fb4" />

### 🤖 vLLM Docker Images

To use vLLM optimized for RDNA4 and CDNA3:
Use the container image you need.
```bash
# RDNA4 build
sudo docker pull rocm/vllm-dev:open-r9700-08052025
```

<img width="799" height="529" alt="{CFEDF465-C100-4945-9A40-907B2A225402}" src="https://github.com/user-attachments/assets/45d71292-4bc1-4d3f-afc7-8dc2611d0b38" />

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

<img width="1042" height="273" alt="{F27CCEEE-9D11-441D-889F-5EAB77E0788A}" src="https://github.com/user-attachments/assets/61bb00ec-608a-4dd5-bbd5-5938eff259af" />

or `amd-smi`

<img width="804" height="401" alt="{F2FE5F1A-871E-4A40-A730-CA2F8D514078}" src="https://github.com/user-attachments/assets/1e781e2d-643a-4e89-a63d-5e74e1a26534" />

If you need to add a specific GPU, you can use the **passthrough** option.  
First, verify the available GPUs in the `/dev/dri` directory.

<img width="871" height="77" alt="{5CE24323-6294-4E65-9B0F-553A87AED057}" src="https://github.com/user-attachments/assets/30aff011-0a88-442c-a8a4-3e2d7633ba3e" />

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

## 📶 ROCm Bandwidth Test

**AMD’s ROCm Bandwidth Test utility** with the **`tb p2p` (Peer-to-peer device memory bandwidth test)** flag runs a complete set of bandwidth diagnostics.

### What it does

`rocm-bandwidth-test` is a diagnostic tool included in ROCm that measures **memory bandwidth performance** between:

- Host (CPU) ↔ GPU(s)  
- GPU ↔ GPU (if multiple GPUs are installed)  
- GPU internal memory  

### `tb p2p` option

Using the `--run tb p2p` flag runs **Peer-to-peer device memory bandwidth test**, including:

- **Host-to-Device (H2D)** bandwidth  
- **Device-to-Host (D2H)** bandwidth  
- **Device-to-Device (D2D)** bandwidth (for multi-GPU)  
- **Bidirectional / concurrent** bandwidth tests  

Run the P2P test
```bash
sudo /opt/rocm/bin/rocm_bandwidth_test plugin --run tb p2p
```

### Output

The tool prints results in a **matrix format** showing bandwidth (GB/s) between every device pair.

<img width="983" height="1179" alt="{6EAC522F-550D-4881-9C78-11B3A90A555D}" src="https://github.com/user-attachments/assets/039f0f87-79b8-4dd0-856b-d959025b27a4" />

More details about the setup can be verified by
```bash
sudo /opt/rocm/bin/rocm_bandwidth_test plugin --run tb
```

<img width="861" height="275" alt="{4103D9C7-2ECE-42CF-A231-DC1D7004C7BF}" src="https://github.com/user-attachments/assets/e0a1efaf-9c5c-4c6c-b2d9-8ff14cf1b623" />

⚠️ **Caution:**  
Make sure **"Resize BAR"** is enabled in the **SBIOS**.  
If it is disabled, **P2P** will be deactivated, as shown below:

<img width="977" height="777" alt="{FD9B95A3-BEFA-4857-8BBB-8D06A90108F2}" src="https://github.com/user-attachments/assets/cc148322-45b3-4164-b215-521276749f9d" />

More details about the setup can be verified by
```bash
sudo /opt/rocm/bin/rocm_bandwidth_test plugin --run tb
```

<img width="904" height="274" alt="{3F58A790-E952-4BD9-9F0A-B99FD8F0B081}" src="https://github.com/user-attachments/assets/28b1808a-8216-4d7c-b1ea-db599f140056" />

### ⚙️ How to Enable **Resize BAR** in SBIOS (example ASRock WRX90 evo)

1. Enter **SBIOS** by pressing "DEL"

<img width="1007" height="760" alt="{F9649127-0F1F-4E14-8008-1F3782FBBDEF}" src="https://github.com/user-attachments/assets/9685c1a4-ecab-4fea-8e91-dd21b9869c7e" />

3. Navigate to **Advanced**

<img width="1018" height="761" alt="{135D3B4C-0732-4652-A3C0-1224D275A515}" src="https://github.com/user-attachments/assets/b1cdc3ce-b526-4cdc-b44f-71d1119cf6d7" />

5. Go to **PCI Subsystem Settings** and change **Re-Size BAR Support** to **Enable** 

<img width="1016" height="761" alt="{3C54C3DA-8B82-483C-AEA5-D0A511508780}" src="https://github.com/user-attachments/assets/60536e2b-e59f-4486-a1fc-ab3ff33a3cd8" />

