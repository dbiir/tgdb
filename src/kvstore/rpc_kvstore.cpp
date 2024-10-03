
#include "kvstore/rpc_kvstore.hpp"

#include <iostream>

#include <gflags/gflags.h>
#include <butil/logging.h>
#include <butil/time.h>
// #include <brpc/channel.h>
#include "rocksdb_service.pb.h"

namespace rpc_kv_store {

DEFINE_string(attachment, "", "Carry this along with requests");
DEFINE_string(protocol, "baidu_std", "Protocol type. Defined in src/brpc/options.proto");
DEFINE_string(connection_type, "single", "Connection type. Available values: single, pooled, short");
DEFINE_string(server, "10.77.110.146:52013", "IP Address of server");
DEFINE_string(load_balancer, "", "The algorithm for load balancing");
DEFINE_int32(timeout_ms, 0x7fffffff, "RPC timeout in milliseconds");
// DEFINE_int32(timeout_ms, 10000, "RPC timeout in milliseconds");
DEFINE_int32(max_retry, 20, "Max retries(not including the first RPC)"); 
DEFINE_int32(interval_ms, 1000, "Milliseconds between consecutive requests");


rpcKVStore::rpcKVStore() {
  // Initialize the channel, NULL means using default options.
    brpc::ChannelOptions options;
    options.protocol = FLAGS_protocol;
    options.connection_type = FLAGS_connection_type;
    options.timeout_ms = FLAGS_timeout_ms/*milliseconds*/;
    options.max_retry = FLAGS_max_retry;
    if (channel.Init(FLAGS_server.c_str(), FLAGS_load_balancer.c_str(), &options) != 0) {
        LOG(ERROR) << "Fail to initialize channel";
    }else{
      std::cout<<"success to initialize channel\n";
    }
}

rpcKVStore::~rpcKVStore() {}

bool rpcKVStore::Put(const std::string &key, const std::string &value) {
  rocksdb_service::RocksdbService_Stub stub(&channel);
  rocksdb_service::PutRequest     put_request;
  rocksdb_service::PutResponse    put_response;
  
  put_request.set_key(key);
  put_request.set_value(value);

  brpc::Controller* cntl = new brpc::Controller;
  brpc::CallId cid = cntl->call_id();

  stub.PUT(cntl, &put_request, &put_response, NULL);
  return put_response.status();
}

std::optional<std::string> rpcKVStore::Get(const std::string &key){
  rocksdb_service::RocksdbService_Stub stub(&channel);
   // GET
  rocksdb_service::GetRequest     get_request;
  rocksdb_service::GetResponse    get_response;

  get_request.set_key(key);
  
  brpc::Controller* cntl = new brpc::Controller;
  brpc::CallId cid = cntl->call_id();

  stub.GET(cntl, &get_request, &get_response, NULL);
  auto get_value=get_response.value();
  if(get_value=="") return std::nullopt;
  return get_value;
}

bool rpcKVStore::Delete(const std::string &key){
   rocksdb_service::RocksdbService_Stub stub(&channel);
   // DEL
    rocksdb_service::DelRequest     del_request;
    rocksdb_service::DelResponse    del_response;

    del_request.set_key(key);

    brpc::Controller* cntl = new brpc::Controller;
    brpc::CallId cid = cntl->call_id();

    stub.DEL(cntl, &del_request, &del_response, NULL);
    return del_response.status();
}


bool rpcKVStore::BatchPut(const std::vector<std::pair<std::string, std::string>> &versions){
    rocksdb_service::RocksdbService_Stub stub(&channel);
   
    rocksdb_service::BatchPutRequest    batch_put_request;
    rocksdb_service::BatchPutResponse   batch_put_response;
    for (const auto &version : versions) {
      auto put = batch_put_request.add_batchput();
      put->set_key(version.first);
      put->set_value(version.second);
    }

    brpc::Controller* cntl = new brpc::Controller;
    brpc::CallId cid = cntl->call_id();

    stub.BatchPUT(cntl, &batch_put_request, &batch_put_response, NULL);
    return batch_put_response.status();
}

std::pair<std::vector<nlohmann::json>,bool> rpcKVStore::GetVertexInfo(uint64_t gid,uint64_t c_ts,uint64_t c_te,std::string type){
    std::vector<nlohmann::json> history_Delta;
    int try_cnt=0;
    while(try_cnt<10){
      try{
        try_cnt+=1;
        rocksdb_service::RocksdbService_Stub stub(&channel);
        rocksdb_service::VertexInfoRequest    get_vertex_info_request;
        rocksdb_service::VertexInfoResponse   get_vertex_info_response;
        get_vertex_info_request.set_gid(gid);
        get_vertex_info_request.set_cts(c_ts);
        get_vertex_info_request.set_cte(c_te);
        get_vertex_info_request.set_type(type);

        brpc::Controller* cntl = new brpc::Controller;
        brpc::CallId cid = cntl->call_id();
        stub.GETVertexInfo(cntl, &get_vertex_info_request, &get_vertex_info_response, NULL);
        if(cntl->Failed()){
          std::cerr << "RPC failed: " << cntl->ErrorText() << std::endl;
        }else{
          for(int i=0;i<get_vertex_info_response.versions_size();i++){
            history_Delta.push_back(nlohmann::json::parse(get_vertex_info_response.versions(i)));
          }
          return std::make_pair(history_Delta,get_vertex_info_response.anchorflag());
        }
      }catch(...){
        std::cout<<"get vertex info from brpc fail!\n";
      }
    }
    return std::make_pair(history_Delta,false);
}

}  // namespace kvstore
