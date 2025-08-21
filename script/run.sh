#! /bin/bash

if [ ! -d "build" ]; then
  echo "Directory build does not exist, creating it"
  mkdir build
fi

cd build
cmake ..
make

pre_path_name="DATA_PATH"
dataset_name="DATA_NAME"
algorithm="mag"
dim=DIM
top_k=K
threshold=5
R_IP=15
L=60
R=48
C=300
M=64

log_file="log.txt"
if [ $? -eq 0 ]; then
  echo "Build successful"
  efs=(800)
  ./test/test_mag "${pre_path_name}/${dataset_name}/database_${dataset_name}.bin" "${pre_path_name}/${dataset_name}/${dataset_name}.knng" ${L} ${R} ${C} "/home/MAG/benchmark/mag/${dataset_name}.mag" \
  "index" ${dim} ${R_IP} ${M} ${threshold} | tee -a "$log_file"
  for efs in "${efs[@]}"; do
    echo "Running with efs: $efs" | tee -a "$log_file"
    ./test/test_mag "${pre_path_name}/${dataset_name}/database_${dataset_name}.bin" "${pre_path_name}/${dataset_name}/query_${dataset_name}.bin" "/home/MAG/benchmark/mag/${dataset_name}.mag" \
     "$efs" ${top_k} "/home/MAG/benchmark/mag/result_${dataset_name}.txt" "search" ${dim}
    python3 recall.py 
    echo "========================================"
  done

else
  echo "Build failed"
fi