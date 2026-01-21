## 🚀 Installation

### 1️⃣ **System preperation**
Install **Ubuntu 22.04.5 LTS** or **Ubuntu 24.04.3 LTS** (Server or Desktop version).
Install the the automates ROCm 
Download and Install the latest vLLM container (RDNA4 build for Ubuntu 24.04.x (~13.6GB))
```bash
sudo docker pull rocm/vllm-dev:rocm7.1.1_navi_ubuntu24.04_py3.12_pytorch_2.8_vllm_0.10.2rc1
```
start the container
```bash
sudo docker run -it \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    --group-add video \
    rocm/vllm-dev:rocm7.1.1_navi_ubuntu24.04_py3.12_pytorch_2.8_vllm_0.10.2rc1
```

### 2️⃣ **Download the python Benchmark-Script from the Repository**
```bash
wget https://raw.githubusercontent.com/JoergR75/rocm-7.1.1-pytorch-2.11.0-docker-cdna3-rdna4-automated-deployment/refs/heads/main/vLLM/vLLMbench.py
```

<img width="1216" height="276" alt="{DA9A9447-CA91-4CE5-8095-B545AA24E564}" src="https://github.com/user-attachments/assets/9f960a0a-4415-428f-b308-9534df12e867" />

### 3️⃣ **Run the Benchmark**
Without a required hugging face token
```python
python3 vLLMbench.py
```
With required hf token
```python
python3 bench.py \
  --hf-token hf_xxxx
```
**⚠️ Note**: verify if a hf token to access the model will be required. Some models aslo require to accept license notice.

<img width="873" height="294" alt="{29E92554-013D-4450-968F-036282CBA9C6}" src="https://github.com/user-attachments/assets/011e053b-c444-4f3d-b276-cabae5224f2d" />

The installation takes ~15 minutes depending on internet speed and hardware performance.

