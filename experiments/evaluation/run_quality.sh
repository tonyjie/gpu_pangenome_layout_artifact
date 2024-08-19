#!/bin/bash
# Quality Evaluation: run [odgi tension] to check quality comparison (sampled path stress) for CPU and GPU layouts
# Estimate time: 2 hour
# branch: gpu_data_reuse

# Directories inside Docker container
ODGI_BIN="/root/odgi/bin/odgi"
DATASET_DIR="/root/pangenome_dataset"
HOME_DIR="/root/experiments"
WORK_DIR="${HOME_DIR}/evaluation"

NUM_THREAD="32"

LOG_FILE="${WORK_DIR}/run_quality.log"
if [ -f "${LOG_FILE}" ]; then
    rm ${LOG_FILE}
fi

# iterate through all the chromosomes
CHR_NAMES=("chr1" "chr2" "chr3" "chr4" "chr5" "chr6" "chr7" "chr8" "chr9" "chr10" \
"chr11" "chr12" "chr13" "chr14" "chr15" "chr16" "chr17" "chr18" "chr19" "chr20" \
"chr21" "chr22" "chrX" "chrY")

echo "===== Run Quality Evaluation for all the human chromosomes =====" 2>&1 | tee -a ${LOG_FILE}
for chroms in ${CHR_NAMES[@]}; do
    echo "" 2>&1 | tee -a ${LOG_FILE}
    echo "===== Chromosome: ${chroms} =====" 2>&1 | tee -a ${LOG_FILE}
    OG_FILE="${DATASET_DIR}/chroms/${chroms}.og"
    PATH_FILE="${DATASET_DIR}/path_index/${chroms}.xp"

    # CPU Layouts are pre-generated
    LAY_FILE_CPU="${DATASET_DIR}/layouts_cpu/${chroms}.lay"
    # GPU Layouts are just generated by `run_gpu_layout.sh` / you can also directly use the pre-generated layouts. 
    LAY_FILE_GPU="${DATASET_DIR}/layouts_gpu/${chroms}.lay"

    # [odgi tension] check quality for CPU layouts
    echo "=== CPU Layout ===" 2>&1 | tee -a ${LOG_FILE}
    ${ODGI_BIN} tension -i ${OG_FILE} -c ${LAY_FILE_CPU} --threads ${NUM_THREAD} --path-stress 2>&1 | tee -a ${LOG_FILE}
    # [odgi tension] check quality for GPU layouts
    echo "=== GPU Layout ===" 2>&1 | tee -a ${LOG_FILE}
    ${ODGI_BIN} tension -i ${OG_FILE} -c ${LAY_FILE_GPU} --threads ${NUM_THREAD} --path-stress 2>&1 | tee -a ${LOG_FILE}
done