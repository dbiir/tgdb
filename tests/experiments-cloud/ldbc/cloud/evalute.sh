#!/bin/bash
update_num=1000000
scale_factor=1
prefix_path="/home/cloud_results/T-LDBC"
database_directory="--data-directory $prefix_path/database/cloud_db/aeong2"
mgbench_download_dir="$prefix_path/datasets/"
bolt_port="--port 7693"

temp_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base_dir="${temp_dir}/../../../.."
#cloud db 
build_dir="${base_dir}/build_cloud_data_cache"


scripts_dir="${base_dir}/tests/scripts" # scripts directory for test
dataset_root="${mgbench_download_dir}"
aeong_database_root="${database_directory}"


####################################evaluate temporal queries###########################
cd $scripts_dir
number_workers="--num-workers 20"
index_path="--index-cypher-path $dataset_root/ldbc_index.cypher"
temporal_query_path="${prefix_path}/temporal_query"
python_script="evaluate_temporal_q.py"
temporal_q1="--temporal-query-cypher-path $temporal_query_path/IS1_cypher.txt"
temporal_q3="--temporal-query-cypher-path $temporal_query_path/IS3_cypher.txt"
temporal_q4="--temporal-query-cypher-path $temporal_query_path/IS4_cypher.txt"
temporal_q5="--temporal-query-cypher-path $temporal_query_path/IS5_cypher.txt"
temporal_q7="--temporal-query-cypher-path $temporal_query_path/IS7_cypher.txt"

echo "AeonG q1 "
python3 "$python_script" $aeong_binary $client_binary $bolt_port $number_workers $database_directory $index_path $temporal_q1
# echo "AeonG q3 "
# python3 "$python_script" $aeong_binary $client_binary $number_workers $database_directory $index_path $temporal_q3
# echo "AeonG q4 "
# python3 "$python_script" $aeong_binary $client_binary $number_workers $database_directory $index_path $temporal_q4
# echo "AeonG q5 "
# python3 "$python_script" $aeong_binary $client_binary $number_workers $database_directory $index_path $temporal_q5
# echo "AeonG q7 "
# python3 "$python_script" $aeong_binary $client_binary $number_workers $database_directory $index_path $temporal_q7