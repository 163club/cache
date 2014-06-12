//`include "cache_def_pkg.sv"
//import cache_def::*;
`include "globals.sv"

/*cache finite state machine*/
module dm_cache_fsm(input bit clk, input bit rst,
                    input cpu_req_type cpu_req, //CPU request input (CPU->cache)
                    input mem_data_type mem_data, //memory response (memory->cache)
                    output mem_req_type mem_req, //memory request (cache->memory)
                    output cpu_result_type cpu_res //cache result (cache->CPU)
);

  timeunit 1ns;
  timeprecision 1ps;

  /*write clock*/
//  typedef enum {idle, compare_tag, allocate, write_back} cache_state_type;

  /*FSM state register*/
  cache_state_type vstate, rstate;

  /*interface signals to tag memory*/
  cache_tag_type tag_read; //tag read result
  cache_tag_type tag_write; //tag write data
  cache_req_type tag_req; //tag request

  /*interface signals to cache data memory*/
  cache_data_type data_read; //cache line read data
  cache_data_type data_write; //cache line write data
  cache_req_type data_req; //data req

  /*temporary variable for cache controller result*/
  cpu_result_type v_cpu_res;

  /*temporary variable for memory controller request*/
  mem_req_type v_mem_req;

  assign mem_req = v_mem_req; //connect to output ports
  assign cpu_res = v_cpu_res;

 //  /* --------------fsm checker -----------*/
	// fsm_checker checker(.clock(clk),
	// 					.rst(rst),
	// 					.cpu_req(cpu_req),
	// 					.mem_data(mem_data),
	// 					.mem_req(mem_req),
	// 					.cpu_res(cpu_res),
	// 					.c_state(v_state)
	// 					);

  always_comb begin
  /*-------------------------default values for all signals------------*/
    /*no state change by default*/
    vstate = rstate;
    v_cpu_res = '{0, 0}; tag_write = '{0, 0, 0};

    /*read tag by default*/
    tag_req.we = '0;
    /*direct map index for tag*/
    tag_req.index = cpu_req.addr[13:4];

    /*read current cache line by default*/
    data_req.we = '0;
    /*direct map index for cache data*/
    data_req.index = cpu_req.addr[13:4];

    /*modify correct word (32-bit) based on address*/
    data_write = data_read;
    case(cpu_req.addr[3:2])
      2'b00:data_write[31:0] = cpu_req.data;
      2'b01:data_write[63:32] = cpu_req.data;
      2'b10:data_write[95:64] = cpu_req.data;
      2'b11:data_write[127:96] = cpu_req.data;
    endcase

    /*read out correct word(32-bit) from cache (to CPU)*/
    case(cpu_req.addr[3:2])
      2'b00:v_cpu_res.data = data_read[31:0];
      2'b01:v_cpu_res.data = data_read[63:32];
      2'b10:v_cpu_res.data = data_read[95:64];
      2'b11:v_cpu_res.data = data_read[127:96];
    endcase

    /*memory request address (sampled from CPU request)*/
    v_mem_req.addr = cpu_req.addr;
    /*memory request data (used in write)*/
    v_mem_req.data = data_read;
    v_mem_req.rw = '0;

    //------------------------------------Cache FSM-------------------------
    case(rstate)
      /*idle state*/
      idle : begin
        /*If there is a CPU request, then compare cache tag*/
        if (cpu_req.valid)
          vstate = compare_tag;
      end

      /*compare_tag state*/
      compare_tag : begin
        /*cache hit (tag match and cache entry is valid)*/
        if (cpu_req.addr[TAGMSB:TAGLSB] == tag_read.tag && tag_read.valid) begin
          v_cpu_res.ready = '1;
          /*write hit*/
          if (cpu_req.rw) begin
            /*read/modify cache line*/
            tag_req.we = '1; data_req.we = '1;
            /*no change in tag*/
            tag_write.tag = tag_read.tag;
            tag_write.valid = '1;
            /*cache line is dirty*/
            tag_write.dirty = '1;
          end
          /*xaction is fi nished*/
          vstate = idle;
        end
        /*cache miss*/
        else begin
          /*generate new tag*/
          tag_req.we = '1;
          tag_write.valid = '1;
          /*new tag*/
          tag_write.tag = cpu_req.addr[TAGMSB:TAGLSB];
          /*cache line is dirty if write*/
          tag_write.dirty = cpu_req.rw;
          /*generate memory request on miss*/
          v_mem_req.valid = '1;
          /*compulsory miss or miss with clean block*/
          if (tag_read.valid == 1'b0 || tag_read.dirty == 1'b0)
            /*wait till a new block is allocated*/
            vstate = allocate;
          else begin
            /*miss with dirty line*/
            /*write back address*/
            v_mem_req.addr = {tag_read.tag, cpu_req.addr[TAGLSB-1:0]};
            v_mem_req.rw = '1;
            /*wait till write is completed*/
            vstate = write_back;
          end
        end     // else end
      end       // Compare_tag end

      /*wait for allocating a new cache line*/
      allocate: begin
        /*memory controller has responded*/
        if (mem_data.ready) begin
          /* reset request valid signal */
          v_mem_req.valid = '0;
          /*re-compare tag for write miss (need modify correct word)*/
          vstate = compare_tag;
          data_write = mem_data.data;
          /*update cache line data*/
          data_req.we = '1;
        end
      end     // allocate end

      /*wait for writing back dirty cache line*/
      write_back : begin
      /*write back is completed*/
        if (mem_data.ready) begin
          /*issue new memory request (allocating a new line)*/
          v_mem_req.valid = '0;
          v_mem_req.rw = '0;
          vstate = allocate;
        end
      end
    endcase
  end // always_comb end

  always_ff @(posedge(clk)) begin

    // reset some control signals
    //v_mem_req.valid <= '0;

    if (rst)
      rstate <= idle; //reset to idle state
    else
      rstate <= vstate;

    temp_output(cpu_req,mem_data,mem_req,cpu_res);
  end

  /*connect cache tag/data memory*/
  dm_cache_tag ctag(.*);
  dm_cache_data cdata(.*);
endmodule

task temp_output( input cpu_req_type cpu_req, //CPU request input (CPU->cache)
                  input mem_data_type mem_data, //memory response (memory->cache)
                  input mem_req_type mem_req, //memory request (cache->memory)
                  input cpu_result_type cpu_res //cache result (cache->CPU));
                );
  $display("-------- FSM signals: ----------");
  $display("Time: %0d", $time);
  $display("cpu_req:");
  $display("cpu_req.addr   : %h",cpu_req.addr);
  $display("cup_req.data   : %h",cpu_req.data);
  $display("cpu_req.rw     : %d",cpu_req.rw);
  $display("cpu_req.valid  : %d",cpu_req.valid);
  $display("mem_data:");
  $display("mem_data.data  : %h",mem_data.data);
  $display("mem_data.ready : %d",mem_data.ready);
  $display("mem_req:");
  $display("mem_req.addr   : %h",mem_req.addr);
  $display("mem_req.data   : %h",mem_req.data);
  $display("mem_req.rw     : %d",mem_req.rw);
  $display("mem_req.valid  : %d",mem_req.valid);
  $display("cpu_res:");
  $display("cpu__res.data  :%h",cpu_res.data);
  $display("cpu_res.ready  :%d",cpu_res.ready);
  $display("------------------------------\n");
endtask : temp_output