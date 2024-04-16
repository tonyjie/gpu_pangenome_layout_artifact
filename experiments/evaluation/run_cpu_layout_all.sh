#!/bin/bash
# Run CPU Layout for all the human chromosomes, and report its run time in the log file. 
# Estimated time: 30 hours. 
# branch: gpu_data_reuse

# Directories inside Docker container
ODGI_BIN="/root/odgi/bin/odgi"
DATASET_DIR="/root/pangenome_dataset"
HOME_DIR="/root/experiments"
WORK_DIR="${HOME_DIR}/evaluation"

NUM_THREAD="32"

LOG_FILE="${WORK_DIR}/run_cpu_layout_all.log"
if [ -f "${LOG_FILE}" ]; then
    rm ${LOG_FILE}
fi

# iterate through all the chromosomes
CHR_NAMES=("chr1" "chr2" "chr3" "chr4" "chr5" "chr6" "chr7" "chr8" "chr9" "chr10" \
"chr11" "chr12" "chr13" "chr14" "chr15" "chr16" "chr17" "chr18" "chr19" "chr20" \
"chr21" "chr22" "chrX" "chrY")

# CHR_NAMES=("chrY" "DRB1-3123")

echo "===== Run CPU Layout for all the human chromosomes =====" 2>&1 | tee -a ${LOG_FILE}
for chroms in ${CHR_NAMES[@]}; do
    echo "" 2>&1 | tee -a ${LOG_FILE}
    echo "===== Chromosome: ${chroms} =====" 2>&1 | tee -a ${LOG_FILE}
    OG_FILE="${DATASET_DIR}/chroms/${chroms}.og"
    PATH_FILE="${DATASET_DIR}/path_index/${chroms}.xp"

    LAY_FILE="${DATASET_DIR}/layouts_cpu/${chroms}.lay"
    PNG_FILE="${DATASET_DIR}/images_cpu/${chroms}.png"

    set -x
    # [odgi layout]
    ${ODGI_BIN} layout -i ${OG_FILE} -o ${LAY_FILE} -X ${PATH_FILE} --threads ${NUM_THREAD} 2>&1 | tee -a ${LOG_FILE}
    # [odgi draw]
    ${ODGI_BIN} draw -i ${OG_FILE} -c ${LAY_FILE} -p ${PNG_FILE} --threads ${NUM_THREAD}
    set +x
done