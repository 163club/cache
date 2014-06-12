class Environment;

   // /// virtual ports to connect cpu and mem
   // mem_req_type mem_req;
   // mem_data_type mem_data;
   // cpu_req_type cpu_req;
   // cpu_result_type cpu_res;

   // virtual interfaces to connect cache and mem
   virtual mem_interface.MEM mem_intf;
   virtual cache_interface.CACHE_IN cache_in_intf;
   virtual cache_interface.CACHE_OUT cache_out_intf;

   driver drvr;
   receiver rcvr;
   scoreboard sb;
   mailbox dr2sb;
   mailbox rc2sb_cpu;
   mailbox rc2sb_mem;

   function new ( virtual mem_interface.MEM mem_intf,
                  virtual cache_interface.CACHE_IN cache_in_intf,
                  virtual cache_interface.CACHE_OUT cache_out_intf);

   this.mem_intf = mem_intf;
   this.cache_in_intf = cache_in_intf;
   this.cache_out_intf = cache_out_intf;

   $display("%0d : Environment : created env object", $time);
    endfunction:new

    function void build();
    $display(" %0d : Environment : start of build() method",$time);
    dr2sb  = new();
    rc2sb_cpu = new();
    rc2sb_mem = new();
    sb = new(dr2sb, rc2sb_cpu, rc2sb_mem);
    drvr =  new(cache_in_intf, dr2sb);
    rcvr = new(mem_intf, cache_in_intf, cache_out_intf, rc2sb_cpu, rc2sb_mem);
    $display(" %0d : Environment : end of build() method",$time);
    endfunction :build

    task reset();
    $display(" %0d : Environment : start of reset() method",$time);
    $display(" %0d : Environment : end of reset() method",$time);
    endtask : reset

    task cfg_dut();
    $display(" %0d : Environment : start of cfg_dut() method",$time);
    $display(" %0d : Environment : end of cfg_dut() method",$time);
    endtask : cfg_dut

    task start();
    $display(" %0d : Environment : start of start() method",$time);
    fork
      drvr.start();
      rcvr.start();
      sb.start();
    join_any
    $display(" %0d : Environment : end of start() method",$time);
    endtask : start

    task wait_for_end();
    $display(" %0d : Environment : start of wait_for_end() method",$time);
    repeat(100)@(cache_in_intf.clock);
    $display(" %0d : Environment : end of wait_for_end() method",$time);
    endtask : wait_for_end

    task run();
    $display(" %0d : Environment : start of run() method",$time);
    build();
    reset();
    cfg_dut();
    start();
    wait_for_end();
    report();
    $display(" %0d : Environment : end of run() method",$time);
    endtask : run

    task report();
    endtask : report
endclass