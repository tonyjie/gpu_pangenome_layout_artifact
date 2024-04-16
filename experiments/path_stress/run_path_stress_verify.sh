#!/bin/bash
# Usage: bash run_path_stress_verify.sh

# Directories inside Docker container
ODGI_BIN="/root/odgi/bin/odgi"
DATASET_DIR="/root/pangenome_dataset"
HOME_DIR="/root/experiments"
WORK_DIR="${HOME_DIR}/path_stress"

NUM_THREAD="32"

LOG_FILE="${WORK_DIR}/run_path_stress_verify.log"
if [ -f "${LOG_FILE}" ]; then
    rm ${LOG_FILE}
fi

CHR_NAMES=("DRB1-3123_11" "DRB1-3123_13" "DRB1-3123_15" "DRB1-3123_29")

OG_FILE="${DATASET_DIR}/chroms/DRB1-3123.og"
PATH_FILE="${DATASET_DIR}/path_index/DRB1-3123.xp"

echo "===== Run Path Stress Verification with chromosome: HLA-DRB1 =====" 2>&1 | tee -a ${LOG_FILE}
for chroms in ${CHR_NAMES[@]}; do
    LAY_FILE="${WORK_DIR}/${chroms}.lay"
    # [odgi tension] check quality for layouts
    echo "=== Layout: ${chroms} ===" 2>&1 | tee -a ${LOG_FILE}
    ${ODGI_BIN} tension -i ${OG_FILE} -c ${LAY_FILE} --threads ${NUM_THREAD} --path-stress 2>&1 | tee -a ${LOG_FILE}
done