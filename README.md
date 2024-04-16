# GPU-Pangenome-Layout Artifact
This repository includes the script to reproduce the central evaluation in the paper. 

The source code is pre-built in the [Docker image](https://hub.docker.com/r/tonyjie/gpu-pangenome-layout). 

The detailed instructions are provided in the Artifact Evaluation Appendix. 


## Prerequisite
We require the NVIDIA Container Toolkit to set up environments, please follow instructions from the [installation guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installation). For convenience, we also provide the installation script below (extracted from official guide):

```
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

## Setup Docker Image
Pull the docker image from Dockerhub. 
```
docker pull tonyjie/gpu-pangenome-layout
```

## Download the dataset Zenodo file (Supplemental Figures)
Download the raw data from the uploaded [Zenodo file](https://zenodo.org/records/10976317). Then unzip the file. 


```
# download zenodo file
wget https://zenodo.org/records/10976317/files/pangenome_dataset.tar.gz?download=1
# unzip the file
tar -xvf pangenome_dataset.tar.gz
```
Now you save this directory under `/your/path/to/pangenome_dataset/`. 


## Download the artifact script from Github
```
git clone git@github.com:tonyjie/gpu_pangenome_layout_artifact.git
```
Now you save this directory under `/your/path/to/experiments`

## Run Docker container with mounted volume of dataset and artifact script
Remember to replace `/your/path/to/pangenome_dataset/` and `/your/path/to/experiments` with your own local directories. 

```
docker run --gpus all -v /your/path/to/pangenome_dataset/:/root/pangenome_dataset -v /your/path/to/experiments:/root/experiments -it tonyjie/gpu-pangenome-layout /bin/bash
```

### Check the GPU support
`nvidia-smi` would give you a list of available GPUs, if you have GPUs on your server, and correctly install the NVIDIA Container Toolkit. 

### Download and Preprocess the dataset (Need 250GB disk space)
We still need to download the raw data, and preprocess to generate the dataset required for evaluation. 

```
cd /root/pangenome_dataset
bash dataset_preprocess.sh
```
This will download the raw data (`.gfa` file), and generate the required dataset (`.og` file and `.xp` path index file) using the other commands of ODGI. 


## Run the evaluation scripts within Docker container

### Central Evaluation
```
cd /root/experiments/evaluation
# All GPU layouts generation
bash run_gpu_layout_all.sh
# Layout quality comparison
bash run_quality.sh
# Generate and compare CPU and GPU layout for a single chromosome
bash run_layout_cpu_gpu_single.sh chr12
# Optional: all CPU layouts generation
bash run_cpu_layout_all.sh
```

### Path Stress
```
cd /root/path_stress
bash run_path_stress_verify.sh
```