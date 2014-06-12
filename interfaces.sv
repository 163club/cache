`ifndef INTERFACES_SV
 `define INTERFACES_SV
//`include "cache_def_pkg.sv"
//import cache_def::*;
///// interface decearation for mem /////
interface mem_interface(input bit clock);
   mem_req_type mem_req;
   mem_data_type mem_data;

   clocking cb@(posedge clock);
      //default input #1 output #1;
      input mem_req;
      input mem_data;
   endclocking // cb

   // clocking cb_cache_in@(posedge clock);
   //    input mem_data;
   //    output mem_req;
   // endclocking

   modport MEM(clocking cb, input clock);
   //modport cache_in(clocking cb_cache_in, input clock);

endinterface // mem_interface

///// interface declearation for CPU .....
interface cache_interface(input bit clock);

   mem_req_type mem_req;
   mem_data_type mem_data;
   cpu_req_type cpu_req;
   cpu_result_type cpu_res;
   logic reset;

   clocking cb_in@(posedge clock);
      //default input #1 output #1;
      output   cpu_req;
      output    mem_data;
   endclocking

   clocking cb_out@(posedge clock);
      input    cpu_res;
      input   mem_req;
   endclocking // cb

   // clocking cb_cache_in@(posedge clock);
   //    input cpu_res;
   //    output cpu_req;
   // endclocking

   modport CACHE_IN(clocking cb_in, output reset, input clock);
   modport CACHE_OUT(clocking cb_out, input clock);
   //modport cache_in(clocking cb_cache_in, input clock);

endinterface // cpu_interface
`endif //  `ifndef INTERFACES_SV
