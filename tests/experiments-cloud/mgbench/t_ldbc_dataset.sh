#!/bin/bash
update_num=1000000
memgraph_binary=/home/AeonG_Cloud/build_non_cloud_non_data_cache/memgraph 
scale_factor=1
prefix_path="/home/cloud_results/T-LDBC"
database_directory="--data-directory $prefix_path/database/db/aeong"
mgbench_download_dir="$prefix_path/datasets/"

temp_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base_dir="${temp_dir}/../../.."
build_dir="${base_dir}/build_non_cloud_non_data_cache"
scripts_dir="${base_dir}/tests/scripts" # scripts directory for test
dataset_root="${mgbench_download_dir}"
aeong_database_root="${database_directory}"

####################################create graph operation###########################
# echo "Create graph operation query statements"
graph_op_path="${prefix_path}/graph_op/"
# peak_vertices_path="${prefix_path}peak_vertices/"
# echo $graph_op_path
# rm -rf $graph_op_path
# mkdir -p $graph_op_path
# rm -rf $peak_vertices_path
# mkdir -p $peak_vertices_path
# update_num_arg="--num-op $update_num"
# write_path="--write-path $prefix_path"
# dataset_path="--ldbc-dataset-path ${dataset_root}/original_csv/"
# python_script="$base_dir/tests/benchmarks/T-LDBC/create_graph_op_queries.py"
# output=$(python3 $python_script $update_num_arg $dataset_path $write_path)

####################################create temporal graph database###########################
#Create AeonG temporal database, get graph operation latency, and get space
cd $scripts_dir
# rm -rf $aeong_database_root
aeong_binary="--aeong-binary ${build_dir}/memgraph"
client_binary="--client-binary ${build_dir}/tests/mgbench/client"
number_workers="--num-workers 20"
echo $database_directory

original_dataset_path="--original-dataset-cypher-path $dataset_root/ldbc.cypher"
index_path="--index-cypher-path $dataset_root/ldbc_index.cypher"
graph_op_cypher_path="--graph-operation-cypher-path $graph_op_path/cypher.txt"
python_script="create_temporal_database.py"
# echo "=============AeonG create database, it cost time==========="
# python3 $python_script $aeong_binary $client_binary $bolt_port $original_dataset_path $number_workers $database_directory $index_path $graph_op_cypher_path $benchmark_type


####################################create temporal queries###########################
# echo "=============Various temporal query performance==========="
# prefix_path="$base_dir/tests/results/"
# op_num="--num-op $update_num"
# min_time="--min-time 90791306"
# max_time="--max-time 92732774"
# write_path="--write-path $prefix_path/T-LDBC/"
temporal_query_path="${prefix_path}/temporal_query"
# echo $temporal_query_path
# rm -rf $temporal_query_path
# mkdir -p $temporal_query_path
# python_script="$base_dir/tests/benchmarks/T-LDBC/create_temporal_query.py"
# output=$(python3 "$python_script" $op_num $min_time $max_time $write_path)


####################################evaluate temporal queries###########################
# aeong_binary="--aeong-binary ${build_dir}/memgraph"
# client_binary="--client-binary ${build_dir}/tests/mgbench/client"
number_workers="--num-workers 1"
index_path="--index-cypher-path $dataset_root/ldbc_index.cypher"
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
