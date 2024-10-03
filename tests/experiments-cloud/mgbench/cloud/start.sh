#!/bin/bash
update_num=320000 #$1 #320000
memgraph_binary=/home/AeonG_Cloud/build_cloud_data_cache
prefix_path="/home/cloud_results/T-mgBench"
database_directory="--data-directory $prefix_path/database/cloud_db/aeong"
mgbench_download_dir="$prefix_path/datasets/"
bolt_port="--port 7590"

temp_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base_dir="${temp_dir}/../../../../"
scripts_dir="${base_dir}/tests/scripts" # scripts directory for test
dataset_root="${mgbench_download_dir}"
aeong_database_root="${database_directory}"

cd $scripts_dir
####################################create temporal graph database###########################
#Create AeonG temporal database, get graph operation latency, and get space
aeong_binary="--aeong-binary ${memgraph_binary}/memgraph"
client_binary="--client-binary ${memgraph_binary}/tests/mgbench/client"
number_workers="--num-workers 20"
original_dataset="--original-dataset-cypher-path $mgbench_download_dir/cypher.cypher"
index_path="--index-cypher-path $mgbench_download_dir/cypher_index.cypher"
graph_op_cypher_path="--graph-operation-cypher-path $graph_op_path/cypher.txt"
python_script="create_temporal_database.py"
# echo "=============AeonG create database, it cost time==========="
echo $database_directory
echo $bolt_port
echo $aeong_binary
python3 "$python_script" $aeong_binary $bolt_port $client_binary $number_workers $database_directory $original_dataset $index_path $graph_op_cypher_path
