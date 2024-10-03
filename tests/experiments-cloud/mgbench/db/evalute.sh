#!/bin/bash
update_num=320000 #$1 #320000
memgraph_binary=/home/AeonG_Cloud/build_non_cloud_data_cache
prefix_path="/home/cloud_results/T-mgBench"
database_directory="--data-directory $prefix_path/database/db/aeong"
mgbench_download_dir="$prefix_path/datasets/"
bolt_port="--port 7689"

temp_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base_dir="${temp_dir}/../../../../"
scripts_dir="${base_dir}/tests/scripts" # scripts directory for test
dataset_root="${mgbench_download_dir}"
aeong_database_root="${database_directory}"

cd $scripts_dir
####################################evaluate temporal queries###########################
aeong_binary="--aeong-binary ${memgraph_binary}/memgraph"
client_binary="--client-binary ${memgraph_binary}/tests/mgbench/client"
number_workers="--num-workers 20"
python_script="evaluate_temporal_q.py"
index_path="--index-cypher-path ${mgbench_download_dir}/cypher_index.cypher"
temporal_query_path=$prefix_path"/temporal_query"
temporal_q1="--temporal-query-cypher-path $temporal_query_path/cypher_Q1.txt"
temporal_q2="--temporal-query-cypher-path $temporal_query_path/cypher_Q2.txt"
temporal_q3="--temporal-query-cypher-path $temporal_query_path/cypher_Q3.txt"
temporal_q4="--temporal-query-cypher-path $temporal_query_path/cypher_Q4.txt"
echo "AeonG q1 mix"
python3 "$python_script" $aeong_binary $client_binary $bolt_port $number_workers $database_directory $index_path $temporal_q1
# echo "AeonG q2 mix"
# python3 "$python_script" $aeong_binary $client_binary $bolt_port $number_workers $database_directory $index_path $temporal_q2
# echo "AeonG q3 mix"
# python3 "$python_script" $aeong_binary $client_binary $bolt_port $number_workers $database_directory $index_path $temporal_q3
# echo "AeonG q4 mix"
# python3 "$python_script" $aeong_binary $client_binary $bolt_port $number_workers $database_directory $index_path $temporal_q4
