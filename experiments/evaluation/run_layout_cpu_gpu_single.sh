#!/bin/bash
# Run on a single chromosome using CPU and GPU layouts, and compare their run time, and quality. 
# Usage: bash run_layout_cpu_gpu_single.sh chrY
# branch: gpu_data_reuse

# Directories inside Docker container
ODGI_BIN="/root/odgi/bin/odgi"
DATASET_DIR="/root/pangenome_dataset"
HOME_DIR="/root/experiments"
WORK_DIR="${HOME_DIR}/evaluation"


NUM_THREAD="32"

chroms=$1

LOG_FILE="${WORK_DIR}/run_layout_cpu_gpu_single_${chroms}.log"
if [ -f "${LOG_FILE}" ]; then
    rm ${LOG_FILE}
fi

echo "===== Compare CPU and GPU layouts for Chromosome: ${chroms} =====" 2>&1 | tee -a ${LOG_FILE}

OG_FILE="${DATASET_DIR}/chroms/${chroms}.og"
PATH_FILE="${DATASET_DIR}/path_index/${chroms}.xp"

# === CPU ===
echo "=== Running CPU Layouts ===" 2>&1 | tee -a ${LOG_FILE}
LAY_FILE_CPU="${DATASET_DIR}/layouts_cpu/${chroms}.lay"
PNG_FILE_CPU="${DATASET_DIR}/images_cpu/${chroms}.png"
# [odgi layout] for CPU
${ODGI_BIN} layout -i ${OG_FILE} -o ${LAY_FILE_CPU} -X ${PATH_FILE} --threads ${NUM_THREAD} 2>&1 | tee -a ${LOG_FILE}
# [odgi draw] for CPU
${ODGI_BIN} draw -i ${OG_FILE} -c ${LAY_FILE_CPU} -p ${PNG_FILE_CPU} --threads ${NUM_THREAD}
# [odgi tension] for CPU
${ODGI_BIN} tension -i ${OG_FILE} -c ${LAY_FILE_CPU} --threads ${NUM_THREAD} --path-stress 2>&1 | tee -a ${LOG_FILE}

# === GPU ===
echo "=== Running GPU Layouts ===" 2>&1 | tee -a ${LOG_FILE}
LAY_FILE_GPU="${DATASET_DIR}/layouts_gpu/${chroms}.lay"
PNG_FILE_GPU="${DATASET_DIR}/images_gpu/${chroms}.png"
# [odgi layout] for GPU
${ODGI_BIN} layout -i ${OG_FILE} -o ${LAY_FILE_GPU} -X ${PATH_FILE} --threads ${NUM_THREAD} --gpu 2>&1 | tee -a ${LOG_FILE}
# [odgi draw] for GPU
${ODGI_BIN} draw -i ${OG_FILE} -c ${LAY_FILE_GPU} -p ${PNG_FILE_GPU} --threads ${NUM_THREAD}
# [odgi tension] for GPU
${ODGI_BIN} tension -i ${OG_FILE} -c ${LAY_FILE_GPU} --threads ${NUM_THREAD} --path-stress 2>&1 | tee -a ${LOG_FILE}
