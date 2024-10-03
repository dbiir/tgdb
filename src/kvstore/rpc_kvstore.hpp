#include <filesystem>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "utils/exceptions.hpp"

#include <google/protobuf/descriptor.h>

#include <brpc/channel.h>
#include "../../libs/json/json.hpp"


namespace rpc_kv_store {

/**
 * Abstraction used to manage key-value pairs. The underlying implementation
 * guarantees thread safety and durability properties.
 */
class rpcKVStore final {
 public:

  rpcKVStore();

  ~rpcKVStore();


  bool Put(const std::string &key, const std::string &value);

  std::optional<std::string> Get(const std::string &key);

  bool Delete(const std::string &key);

  bool BatchPut(const std::vector<std::pair<std::string, std::string>> &versions);

  std::pair<std::vector<nlohmann::json>,bool> GetVertexInfo(uint64_t gid,uint64_t c_ts,uint64_t c_te,std::string type);

 private:
  brpc::Channel channel;
};

}  // namespace kvstore
