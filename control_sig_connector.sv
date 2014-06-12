module sig_connector(   input   cache_state_type vstate, rstate,
                        input   cache_tag_type tag_read, tag_write,
                        input   cahce_data_type data_read, data_write,
                        input   cache_req_type tag_reg, data_req,);
    timeunit 1ns;
    timeprecision 1ps;

