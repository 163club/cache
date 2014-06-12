`ifndef TESTCASE_SV
 `define TESTCASE_SV
// `include "cache_def_pkg.sv"
// import cache_def::*;

program testcase(  mem_interface.MEM mem_intf,
                    cache_interface.CACHE_IN cache_in_intf,
                    cache_interface.CACHE_OUT cache_out_intf
		              );
  Environment env;
  packet pkt;

  initial begin
    $display("******** Start of test case ********");
    pkt = new();
    env = new(mem_intf, cache_in_intf, cache_out_intf);
    env.build();
    env.drvr.data_pkt = pkt;
    env.reset();
    env.cfg_dut();
    env.start();
    env.wait_for_end();
    env.report();

    #1000;
  end

  final
    $display("******** End of testcase ***********");

endprogram // testcase
`endif //  `ifndef TESTCASE_SV

// program test;

//   packet pkt1 = new();
//   packet pkt2 = new();

//   cpu_req_type cpu_req;

//   initial
//   repeat(10)
//   if(pkt1.randomize) begin
//     $display("Randomization Sucessesfull.");
//     pkt1.display();
//     cpu_req = pkt1.cpu_req_pack();
//     pkt2 = new();
//     pkt2.cpu_req_unpack(cpu_req);
//     if(pkt2.compare(pkt1))
//       $display("Compare succeed!");
//     else
//       $display("ERROR: compare failed");
//   end
//   else
//     $display("*** Randomization Failed ***");

// endprogram

// class testcase;

//   function new( mem_interface.MEM mem_intf,
//                 cache_interface.CACHE_IN cache_in_intf,
//                 chace_interface.CACHE_OUT cache_out_intf);
//   endfunction: new
// endclass