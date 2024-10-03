#!/bin/bash
update_num=1000000
scale_factor=1
prefix_path="/home/cloud_results/T-LDBC"
database_directory="--data-directory $prefix_path/database/db/aeong2"
mgbench_download_dir="$prefix_path/datasets/"
bolt_port="--port 7694"

temp_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base_dir="${temp_dir}/../../../.."
#cloud db 
build_dir="${base_dir}/build_non_cloud_data_cache"


scripts_dir="${base_dir}/tests/scripts" # scripts directory for test
dataset_root="${mgbench_download_dir}"
aeong_database_root="${database_directory}"

####################################start temporal graph database###########################
#Create AeonG temporal database, get graph operation latency, and get space
cd $scripts_dir
aeong_binary="--aeong-binary ${build_dir}/memgraph"
client_binary="--client-binary ${build_dir}/tests/mgbench/client"
number_workers="--num-workers 20"
original_dataset_path="--original-dataset-cypher-path $dataset_root/ldbc.cypher"
index_path="--index-cypher-path $dataset_root/ldbc_index.cypher"
graph_op_cypher_path="--graph-operation-cypher-path $graph_op_path/cypher.txt"
python_script="create_temporal_database.py"
echo $database_directory
echo $aeong_binary
python3 $python_script $aeong_binary $client_binary $bolt_port $original_dataset_path $number_workers $database_directory $index_path $graph_op_cypher_path $benchmark_type

