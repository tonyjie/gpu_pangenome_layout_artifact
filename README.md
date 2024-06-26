# GPU-Pangenome-Layout Artifact
This repository includes the script to reproduce the central evaluation in the paper. 

This README explains the instructions for Artifact Evaluation (AE). 
The descriptions for each artifact are provided in the Artifact Description (AD) appendix. 

There are 3 major components for this AE, including
- Pre-built Docker image. 
- Dataset and Supplemental figures. 
- Scripts to reproduce the central experimental results. 

## 1. Pre-built Docker Image
We provide a pre-built [Docker image](https://hub.docker.com/r/tonyjie/gpu-pangenome-layout) that includes the source code of our GPU implementation which is already integrated into the pipeline, and the baseline CPU implementation. It also includes the GPU implementation of the
quantitative metric proposed. 


### Prerequisite
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

### Pull Docker Image
Pull the docker image from Dockerhub. 
```
docker pull tonyjie/gpu-pangenome-layout
```


## 2. Dataset and Supplemental Figures
Dataset used in the evaluation is the human pangenome reference dataset released by the [HPRC](https://github.com/human-pangenomics/hpp_pangenome_resources). 
Supplemental figures of both CPU and GPU-generated layouts used in the paper are included as well. 

We pack them together into this uploaded [Zenodo file](https://zenodo.org/records/10976317). 

### Instructions to download
```
# download zenodo file
wget https://zenodo.org/records/10976317/files/pangenome_dataset.tar.gz?download=1
# unzip the file
tar -xvf pangenome_dataset.tar.gz
```
`/your/path/to/pangenome_dataset/` is the saved directory path. 

### Structure of this Directory
```
pangenome_dataset/
├── dataset_preprocess.sh
├── chroms/ (empty dir)
├── path_index/ (empty dir)
├── layouts_cpu/
│   ├── chr1.lay
│   ├── ...
│   └── chrY.lay
├── layouts_gpu/
│   ├── chr1.lay
│   ├── ...
│   └── chrY.lay
├── images_cpu/
│   ├── chr1.png
│   ├── ...
│   └── chrY.png
└── images_gpu/
    ├── chr1.png
    ├── ...
    └── chrY.png
```

- `dataset_preprocess.sh` is the script to download and preprocess the dataset (need 250GB disk space). You should run this within the Docker container following the later instructions. We cannot provide the entire dataset on Zenodo because it exceeds the file size limit. Therefore, we provide the link and download commands in this script. 
- `chroms/` and `path_index/` are currently two empty directories. The downloaded and preprocessed dataset will be saved in these directories. 
- `layouts_cpu/` and `layouts_gpu/` include the layout binary files for 24 whole-chromosome pangenomes. They are pre-generated by our run with the original CPU implementation and our GPU implementation. 
- `images_cpu/` and `images_gpu/` include the **layout figures** for 24 whole-chromosome pangenomes. They are the rendered layouts using [`odgi draw`](https://odgi.readthedocs.io/en/latest/rst/commands/odgi_draw.html) command. They are pre-generated, and included here as the supplemental figures. Therefore, you can have a first look by comparing the layout figures of CPU and GPU without spend hours generating all the figures on your own. 


### Compare CPU and GPU-generated layout images by visual inspection
For each chromosome, you can compare the CPU-generated and GPU-generated layout images by visual inspection from `images_cpu/` and `images_gpu/`. 
Human eyes are hard to tell the difference between them. 
GPU layouts show the same structural variants of the pangenomes, and provide all the information that genomics researchers need from the pangenome layout. 

You can also validate the correctness of layout figures by comparing them to the [original algorithm paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10542513/) Fig. 2. 

## 3. Artifact Scripts to reproduce key results
Artifact scripts are included in the current Github repo. 
They are used to reproduce 
- the experimental results of the central evaluation in the paper, including the comparison of run time and layout quality between CPU and GPU. 
- the experimental results of the sampled path stress. 

The artifact scripts are run within the docker container. 

### Instructions to download
```
git clone git@github.com:tonyjie/gpu_pangenome_layout_artifact.git
```
`/your/path/to/gpu_pangenome_layout_artifact/` is the saved directory path. 


### Run Docker container with mounted volume of dataset and artifact script
Remember to replace `/your/path/to/pangenome_dataset/` and `/your/path/to/gpu_pangenome_layout_artifact/experiments` with your own local directories. 

```
docker run --gpus all -v /your/path/to/pangenome_dataset/:/root/pangenome_dataset -v /your/path/to/gpu_pangenome_layout_artifact/experiments:/root/experiments -it tonyjie/gpu-pangenome-layout /bin/bash
```
Now you run the container in an interactive mode with the mounted dataset and artifact scripts. 

### Check the GPU support
`nvidia-smi` would give you a list of available GPUs, if you have GPUs on your server, and correctly install the NVIDIA Container Toolkit. 


### Download and Preprocess the dataset (Need 250GB disk space, 1-2 hours)
We still need to download the raw data, and preprocess them to generate the dataset required for evaluation. 

```
cd /root/pangenome_dataset
bash dataset_preprocess.sh
```
This will download the raw data (`.gfa` file), and generate the required dataset (`.og` file and `.xp` path index file) using the other commands of ODGI. 
They will be saved into `chroms/` and `path_index/` directories mentioned above. 

The expected reproduction time for downloading and generating all the dataset is 1-2 hours. 

### Run the evaluation scripts: Central Evaluation
It is used to reproduce the results of the central evaluation in the paper, including the run time speedup and layout quality comparison. 
It supports the contribution of GPU acceleration without layout quality degradation. 
It also supports the usefulness of the quantitative metric proposed.


- **PLEASE DON'T** copy and run all the following commands together. 

Since generating all the layouts with the CPU baseline requires more than 30 hours, it is not feasible during AE. 
Therefore, we leave the full experiment (including running CPU baseline) as the optional one, and directly provide the generated CPU layouts for the layout quality comparison. 

```
cd /root/experiments/evaluation

# 1. All GPU layouts generation: 1-2 hours
bash run_gpu_layout_all.sh

# 2. Layout quality comparison: 3 hours
bash run_quality.sh

# 3. Optional: generate and compare CPU and GPU layout for a single chromosome: 1 hours for Chr.12
bash run_layout_cpu_gpu_single.sh chr12

# 4. Optional: all CPU layouts generation: 30 hours
bash run_cpu_layout_all.sh
```

1. All GPU layouts generation. The generated GPU layouts will replace the previous layouts. The log file will record the run time of GPU layouts, which should basically align with the result in the paper. 
2. Layout quality comparison. It will compute the path-sampled-stress of the pre-generated CPU layouts and newly-generated GPU layouts. 
3. Generate and compare CPU and GPU layout for a single chromosome. Since CPU baseline is time-consuming, you might only test the CPU baseline performance with a single chromosome instead of the entire dataset due to the time limit. 
4. All CPU layouts generation. Then you can run (2) again to compare the CPU and GPU layouts. 

The expected results include
- **Run Time Speedup**. GPU layout is minute-scale, while CPU layout is hour-scale.
- **Layout Quality Comparison: Metric**. With a quantitative metric of sampled path stress, we see the layout quality is similar for the CPU and GPU layouts. 
- **Layout Quality Comparison: Visual Inspection**. By comparing the generated images of CPU and GPU layouts, we do not find noticeable differences.

### Run the evaluation scripts: Central Evaluation: Path Stress
It is used to reproduce the results of the sampled path stress section in the paper. 
It verifies the usefulness of the proposed quantitative metric, demonstrating that it can correctly reveal the layout quality.


```
cd /root/path_stress
# Compute the sampled path stress with varying qualities: 1 minute
bash run_path_stress_verify.sh
```

The script will compute the sampled path stress for four given layouts with varying qualities.

By checking the quantitative metric and visually inspecting the layout figures, we verify the usefulness of the sampled path stress.
