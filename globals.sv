`ifndef GLOBALS_SV
`define GLOBALS_SV

typedef enum {idle, compare_tag, allocate, write_back} cache_state_type;
int error = 0;
int num_of_pkts = 10;
`endif