//`include "cache_def_pkg.sv"
//import cache_def::*;
module dm_mem(	input	bit clk,
				input	mem_req_type mem_req, // cache-> mem
				output	mem_data_type mem_data // mem -> cache
				);

timeunit 1ns;
timeprecision 1ps;

bit [127:0] memory[int];
bit [31:0] address;
bit [127:0] rand_num;

assign address = mem_req.addr>>4;

always_ff @(posedge(clk)) begin
	mem_data.ready = 1'b0;
	if (mem_req.valid) begin
		if(mem_req.rw)
			memory[address] = mem_req.data;
		else begin
			if(memory.exists(address))
				mem_data.data = memory[address];
			else begin
				if(std::randomize(rand_num)) begin
					mem_data.data = rand_num;
					//$display("----- MEM randomization -----");
					//$display("rand_num: %h\n",rand_num);
				end
				else
					$display("----- MEM randomization failed!!!-----");
			end
		end

		mem_data.ready = 1'b1;
	end
end
endmodule

