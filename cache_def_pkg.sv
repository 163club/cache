`ifndef CACHE_DEF_PKG_SV
`define CACHE_DEF_PKG_SV
timeunit 1ns;
timeprecision 1ps;
package cache_def;
 // data structures for cache tag & data
 
 parameter int TAGMSB = 31; //tag msb
 parameter int TAGLSB = 12; //tag lsb
 parameter int CACHE_INDEX = 128;
 parameter int INDEX_BIT = 7;
 parameter int CACHE_LINE_SIZE = 256;
 
 //data structure for cache tag
 typedef struct packed {
    bit valid; //valid bit
    bit dirty; //dirty bit
    bit [TAGMSB:TAGLSB]tag; //tag bits
 }cache_tag_type;
 
 //data structure for cache memory request
 typedef struct {
    bit [INDEX_BIT-1:0]index; //7-bit index
    bit we; //write enable
 }cache_req_type;
 
 //128-bit cache line data
 typedef bit [127:0] cache_data_type;
 
 // data structures for CPU<->Cache controller interface 
 // CPU request (CPU->cache controller)
 typedef struct {
    bit [31:0]addr; //32-bit request addr
    bit [31:0]data; //32-bit request data (used when write)
    bit rw; //request type : 0 = read, 1 = write
    bit valid; //request is valid
 }cpu_req_type;
 
 // Cache result (cache controller->cpu)
 typedef struct {
    bit [31:0]data; //32-bit data
    bit ready; //result is ready
 }cpu_result_type;
 
 //---------------------------------------------------------------------
 // data structures for cache controller<->memory interface
 
 // memory request (cache controller->memory)
 typedef struct {
    bit [31:0]addr; //request byte addr
    bit [127:0]data; //128-bit request data (used when write)
    bit rw; //request type : 0 = read, 1 = write
    bit valid; //request is valid
 }mem_req_type;
 
 // memory controller response (memory -> cache controller)
 typedef struct {
    cache_data_type data; //128-bit read back data
    bit ready; //data is ready
 }mem_data_type;
 
endpackage

`endif