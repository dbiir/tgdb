find_package(gflags REQUIRED)
find_package(BZip2 REQUIRED)
find_package(ZLIB REQUIRED)

option(LINK_SO "Whether examples are linked dynamically" OFF)

find_path(LEVELDB_INCLUDE_PATH NAMES leveldb/db.h)
find_library(LEVELDB_LIB NAMES leveldb)
if ((NOT LEVELDB_INCLUDE_PATH) OR (NOT LEVELDB_LIB))
    message(FATAL_ERROR "Fail to find leveldb")
endif()
include_directories(${LEVELDB_INCLUDE_PATH})

find_path(BRPC_INCLUDE_PATH NAMES brpc/server.h)
if(LINK_SO)
    find_library(BRPC_LIB NAMES brpc)
else()
    find_library(BRPC_LIB NAMES libbrpc.a brpc)
endif()
if((NOT BRPC_INCLUDE_PATH) OR (NOT BRPC_LIB))
    message(FATAL_ERROR "Fail to find brpc")
endif()
include_directories(${BRPC_INCLUDE_PATH})

# STATIC library used to store key-value pairs
add_library(mg-kvstore STATIC kvstore.cpp)
target_link_libraries(mg-kvstore stdc++fs mg-utils rocksdb BZip2::BZip2 ZLIB::ZLIB gflags)

add_library(mg-rpckvstore STATIC rpc_kvstore.cpp rocksdb_service.pb.cc)
target_link_libraries(mg-rpckvstore ${BRPC_LIB} protobuf ${LEVELDB_LIB} )

