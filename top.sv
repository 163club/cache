`ifndef TOP_SV
 `define TOP_SV
`include "cache_def_pkg.sv"
import cache_def::*;

module top();
   ///// Clock declaration and generation /////
   bit clock;
   bit rst;

   initial
     forever #10 clock=~clock;

   ///// Memory interface instance /////
   mem_interface mem_intf(clock);

   ///// Cpu interface instance /////
   cache_interface cache_intf(clock);

   ///// Memory ports /////
   //mem_req_type mem_req;
   //mem_data_type mem_data;

   ///// CPU ports /////
   //cpu_req_type cpu_req;
   //cpu_result_type cpu_res;

   ///// Testcase instance /////
   testcase TC( .mem_intf(mem_intf.MEM),
		          .cache_in_intf(cache_intf.CACHE_IN),
		          .cache_out_intf(cache_intf.CACHE_OUT));

   ///// Memory and cache /////
   dm_mem random_mem( .clk(clock),
		                .mem_req(mem_intf.mem_req),
		                .mem_data(mem_intf.mem_data)
		     );

   dm_cache_fsm DUT(  .clk(clock),
		                .rst(cache_intf.reset),
		                .cpu_req(cache_intf.cpu_req),
		                .mem_data(mem_intf.mem_data),
		                .mem_req(mem_intf.mem_req),
		                .cpu_res(cache_intf.cpu_res)
		             );
endmodule // top
`endif //  `ifndef TOP_SV
