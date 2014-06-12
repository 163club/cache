`include "globals.sv"

class coverage;
endclass

module fsm_checker(input bit clock, input bit rst,
                    input cpu_req_type cpu_req, //CPU request input (CPU->cache)
                    input mem_data_type mem_data, //memory response (memory->cache)
                    input mem_req_type mem_req, //memory request (cache->memory)
                    input cpu_result_type cpu_res, //cache result (cache->CPU)
			input cache_state_type c_state //fsm current state
);

	property state_idle_compareTag;
	  @(posedge clock)
	  (c_state == idle) && cpu_req.valid |-> 
		   ##1 (c_state == compare_tag);
	endproperty

   property state_idle_loop;
	  @(posedge clock)
	(c_state == idle)&&(!cpu_req.valid)|->
		 ##1 (c_state == idle);
	endproperty
	
	idle_compareTag: assert property(state_idle_compareTag);
	idle_loop: assert property(state_idle_loop);
endmodule
	