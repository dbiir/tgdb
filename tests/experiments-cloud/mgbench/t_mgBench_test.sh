#!/bin/bash
update_num=320000 #$1 #320000
memgraph_binary=/home/AeonG_Cloud/build/memgraph 
prefix_path="/home/cloud_results/T-mgBench"
database_directory="--data-directory $prefix_path/database/db/aeong"
mgbench_download_dir="$prefix_path/datasets/"
bolt_port="--port 7589"

####################################datasets##########################
# download original dataset
# echo "Prepare datasets"
# mkdir -p /home/cloud_results/datasets/T-mgBench
# dataset_url="https://s3.eu-west-1.amazonaws.com/deps.memgraph.io/dataset/pokec/benchmark/pokec_small_import.cypher"
# curl -o "$mgbench_download_dir/cypher.cypher" "$dataset_url"
# index_url="https://s3.eu-west-1.amazonaws.com/deps.memgraph.io/dataset/pokec/benchmark/memgraph.cypher"
# curl -o "$mgbench_download_dir/cypher_index.cypher" "$index_url"
# echo "Download mgbench dataset completed."

####################################create graph operation###########################
#echo "Create graph operation query statements"
graph_op_path="$prefix_path/graph_op"
# rm -rf "$graph_op_path"
# mkdir -p "$graph_op_path"
update_num_arg="--num-op $update_num"
write_path="--write-path $prefix_path"
dataset_path="--dataset-path $mgbench_download_dir"
python_script="../../benchmarks/T-mgBench/create_graph_op_queries.py"
# python3 "$python_script" $update_num_arg $dataset_path $write_path


####################################create temporal graph database###########################
#Create AeonG temporal database, get graph operation latency, and get space
aeong_binary="--aeong-binary /home/AeonG_Cloud/build/memgraph"
client_binary="--client-binary /home/AeonG_Cloud/build/tests/mgbench/client"
number_workers="--num-workers 10"
# rm -rf $prefix_path/database/aeong
# mkdir -p $prefix_path/database/aeong
original_dataset="--original-dataset-cypher-path $mgbench_download_dir/cypher.cypher"
index_path="--index-cypher-path $mgbench_download_dir/cypher_index.cypher"
graph_op_cypher_path="--graph-operation-cypher-path $graph_op_path/cypher.txt"
python_script="../../scripts/create_temporal_database.py"
# echo "=============AeonG create database, it cost time==========="
# python3 "$python_script" $aeong_binary $bolt_port $client_binary $number_workers $database_directory $original_dataset $index_path $graph_op_cypher_path

####################################create temporal queries###########################
# prefix_path="/home/cloud_results/"
op_num="--num-op $update_num"
min_time="--min-time 453365"
max_time="--max-time 812243"
frequency_type="--frequency-type mix"
write_path="--write-path $prefix_path"
temporal_query_path=$prefix_path"/temporal_query"
# rm -rf temporal_query_path
# mkdir -p temporal_query_path
python_script="../../benchmarks/T-mgBench/create_temporal_query.py"
# python3 "$python_script" $op_num $min_time $max_time $frequency_type $write_path

####################################evaluate temporal queries###########################
number_workers="--num-workers 20"
index_path="--index-cypher-path $mgbench_download_dir/cypher_index.cypher"
bolt_port="--port 7689"
python_script="../../scripts/evaluate_temporal_q.py"
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
