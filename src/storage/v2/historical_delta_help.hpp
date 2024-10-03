#include "storage/v2/history_delta.hpp"
#include "query/db_accessor.hpp"
#include <cstring>
#include <fmt/format.h>

#include <stdlib.h>
#include "utils/flag_validation.hpp"
#include "utils/settings.hpp"
#include <json/json.hpp>
#include "query/serialization/property_value.hpp"

namespace history_delta {

namespace {
enum class ObjectType : uint8_t { MAP, TEMPORAL_DATA };
}  // namespace

nlohmann::json SerializePropertyValueVector(const std::vector<storage::PropertyValue> &values);

nlohmann::json SerializePropertyValueMap(const std::map<std::string, storage::PropertyValue> &parameters);

nlohmann::json SerializePropertyValue(const storage::PropertyValue &property_value) {
  using Type = storage::PropertyValue::Type;
  switch (property_value.type()) {
    case Type::Null:
      return {};
    case Type::Bool:
      return property_value.ValueBool();
    case Type::Int:
      return property_value.ValueInt();
    case Type::Double:
      return property_value.ValueDouble();
    case Type::String:
      return property_value.ValueString();
    case Type::List:
      return SerializePropertyValueVector(property_value.ValueList());
    case Type::Map:
      return SerializePropertyValueMap(property_value.ValueMap());
    case Type::TemporalData:
      const auto temporal_data = property_value.ValueTemporalData();
      auto data = nlohmann::json::object();
      data.emplace("type", static_cast<uint64_t>(ObjectType::TEMPORAL_DATA));
      data.emplace("value", nlohmann::json::object({{"type", static_cast<uint64_t>(temporal_data.type)},
                                                    {"microseconds", temporal_data.microseconds}}));
      return data;
  }
}

nlohmann::json SerializePropertyValueVector(const std::vector<storage::PropertyValue> &values) {
  nlohmann::json array = nlohmann::json::array();
  for (const auto &value : values) {
    array.push_back(SerializePropertyValue(value));
  }
  return array;
}

nlohmann::json SerializePropertyValueMap(const std::map<std::string, storage::PropertyValue> &parameters) {
  nlohmann::json data = nlohmann::json::object();
  data.emplace("type", static_cast<uint64_t>(ObjectType::MAP));
  data.emplace("value", nlohmann::json::object());

  for (const auto &[key, value] : parameters) {
    data["value"][key] = SerializePropertyValue(value);
  }

  return data;
};


//help functions
 bool TemporalCheck(uint64_t object_ts,uint64_t object_te,uint64_t c_ts,uint64_t c_te,std::string type){
  if(type=="as of"){
    if(object_ts<=c_ts & object_te>c_te ){
      return true;
    }
  }
  if(type=="from to"){
      if(object_ts<c_te & object_te>c_ts ){
      return true;
    }
  }
  if(type=="between and"){
      if(object_ts<=c_te & object_te>c_ts ){
      return true;
    }
  }
  return false;
}

std::vector<std::string> splits(const std::string &str, const std::string &pattern){
    std::vector<std::string> res;
    if (str == "")
        return res;
    std::string strs = str + pattern;
    size_t pos = strs.find(pattern);
    while (pos != strs.npos)
    {
      std::string temp = strs.substr(0, pos);
      res.push_back(temp);
      //去掉已分割的字符串,在剩下的字符串中进行分割
      strs = strs.substr(pos + 1, strs.size());
      pos = strs.find(pattern);
    }
    return res;
}

int64_t swap64(const int64_t &v)
{
  return (v >> 56 & 0x00000000000000ff)
    | ((v & 0x00ff000000000000) >> 40 & 0x0000000000ffffff)
    | ((v & 0x0000ff0000000000) >> 24 & 0x000000ffffffffff)
    | ((v & 0x000000ff00000000) >> 8 & 0x00ffffffffffffff)
    | ((v & 0x00000000ff000000) << 8)
    | ((v & 0x0000000000ff0000) << 24)
    | ((v & 0x000000000000ff00) << 40)
    | (v << 56);
}

std::string uint_convert_to_string(const int64_t time,bool realTimeFlagConstant){
    auto size=sizeof(time);
    char *buffer = (char *)std::malloc(size);
    auto test=swap64(time);
    std::memcpy(buffer, &test, size);
    std::string start_str(buffer,size);
    std::free(buffer);
    return start_str;
}

std::tuple<uint64_t,int64_t,int64_t> string_convert_to_uint(std::string res,bool realTimeFlagConstant){
    auto size=sizeof(int64_t);
    auto length=res.length();
    //获取gid
    size_t pos = res.find(":");
    auto get_size=length-2*size-3-pos;
    auto gid_str=res.substr(pos+1,get_size);//3:4 12 20-2*8
    auto gid=(uint64_t)std::stoi(gid_str);
    //处理时间
    auto redo_str1=res.substr(length-size);//12:
    auto redo_str2=res.substr(length-2*size-1,size);//3:12
    char redo[size];
    char redo2[size];
    for(int i=0;i<size;i++){
        redo[i]=redo_str1[i];
        redo2[i]=redo_str2[i];
    }
    auto ts = *(int64_t*) redo2;// redo_str;
    auto te = *(int64_t*) redo;
    ts=swap64(ts);
    te=swap64(te);
    return std::make_tuple(gid,ts,te);
}

void combineVertex(nlohmann::json before_data,nlohmann::json &current_data){
  for (auto it = before_data.begin(); it != before_data.end(); ++it) {
    auto it_key = it.key();
    auto it_value=it.value();
    auto it_iter=current_data.find(it_key);
    if(it_iter==current_data.end()){//如果当前数据没有这种类型，则直接添加
      current_data.emplace(it_key,it_value);
    }else{//否则，需要合并value的json
      if(it_key=="SP"){
        auto now_prop_value = current_data["SP"];
        auto before_prop_value=it_value;
        for(auto before_iter= before_prop_value.begin(); before_iter != before_prop_value.end(); ++before_iter){
          auto before_iter_key = before_iter.key();
          auto before_iter_value=before_iter.value();
          auto bb=now_prop_value.find(before_iter_key);
          if(bb==now_prop_value.end()){
            current_data["SP"].emplace(before_iter_key,before_iter_value);
          }
        }
      }
      else if(it_key=="L"){
        auto &current_info=current_data[it_key];
        for(auto before_label:before_data[it_key]){
          current_info.emplace_back(before_label);
        }  
      }
    }
  }
}

void combineEdge(nlohmann::json before_data,nlohmann::json &current_data){
  for (auto it = before_data.begin(); it != before_data.end(); ++it) {
     auto edge_id = it.key();
     if(edge_id=="TT_TS" || edge_id=="TT_TE" ||edge_id=="Type" ||edge_id=="Fid"||edge_id=="Tid") continue;
     auto edge_jsons=it.value();
     auto it_iter=current_data.find(edge_id);
    if(it_iter==current_data.end()){//如果当前数据没有这个节点的信息，则直接添加
      current_data.emplace(edge_id,edge_jsons);
    }else{
      combineVertex(before_data[edge_id],current_data[edge_id]);
    }
  }
}


const std::string kDeltaPrefix = "D:";
const std::string kRecreatePrefix = "R:";

const std::string kVertexDeltaPrefix = "VD:";
const std::string kVertexAnchorPrefix = "VA:";
const std::string kEdgeDeltaPrefix = "ED:";
const std::string kEdgeAnchorPrefix = "EA:";
const std::string kVertexEdgePrefix = "VE:";

const std::string kVertexTimePrefix="VT:";
const std::string kEdgeTimePrefix="ET:";

}