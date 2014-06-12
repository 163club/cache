class receiver;
    // bit clock;
    // cpu_result_type cpu_res;
    // mem_req_type mem_req;
    // mem_data_type mem_data;
    virtual mem_interface.MEM mem_intf;
    virtual cache_interface.CACHE_IN cache_in_intf;
    virtual cache_interface.CACHE_OUT cache_out_intf;
    mailbox rc2sb_cpu;
    mailbox rc2sb_mem;



    /// constructor
    function new(   virtual mem_interface.MEM mem_intf,
                    virtual cache_interface.CACHE_IN cache_in_intf,
                    virtual cache_interface.CACHE_OUT cache_out_intf,
                    mailbox rc2sb_cpu,
                    mailbox rc2sb_mem);
        this.mem_intf = mem_intf;
        this.cache_in_intf = cache_in_intf;
        this.cache_out_intf = cache_out_intf;
        if(rc2sb_cpu == null || rc2sb_mem == null) begin
            $display(
                "***ERROR***: Receiver to scoreboard mailbox is null");
            $finish;
        end
        else begin
            this.rc2sb_cpu = rc2sb_cpu;
		this.rc2sb_mem = rc2sb_mem;
	end
    endfunction :new

    task start();
        //output pack
        mem_req_pack mem_req_pkg;
        mem_data_pack mem_data_pkg;
        cpu_result_pack cpu_res_pkg;

    	forever begin

            @(posedge mem_intf.clock);

            temp_output();

            //fork begin
                if(mem_intf.cb.mem_req.valid) begin
        			mem_req_pkg = new(mem_intf.cb.mem_req);
        			//put recieved packet into mailbox
                    rc2sb_mem.put(mem_req_pkg);
                    // display received packet
                    $display("----- Received Packet -----");
                    $display("Time: %0d",$time);
                    mem_req_pkg.display();
                    $display("---------------------------");
             	end

                if(mem_intf.cb.mem_data.ready) begin
        			mem_data_pkg = new(mem_intf.cb.mem_data);
                    rc2sb_mem.put(mem_data_pkg);
                    // display received packet
                    $display("----- Received Packet -----");
                    $display("Time: %0d",$time);
                    mem_data_pkg.display();
                    $display("---------------------------");
    		    end

                if(cache_out_intf.cb_out.cpu_res.ready) begin
                    cpu_res_pkg = new(cache_out_intf.cb_out.cpu_res);
                    rc2sb_mem.put(cpu_res_pkg);
                    // display received packet
                    $display("----- Received Packet -----");
                    $display("Time: %0d",$time);
                    cpu_res_pkg.display();
                    $display("---------------------------");
                end
    		//end join
    	end
    endtask : start

    task temp_output();
        $display("\n----- Control Signal-----");
        $display("%0d : Receiver: control signal:", $time);
        // $display("cpu_req.valid: %d",
        //     cache_in_intf.cb_in.cpu_req.valid);
        $display("cpu_res.ready: %d",
            cache_out_intf.cb_out.cpu_res.ready);
        $display("mem_req.valid: %d",
            mem_intf.cb.mem_req.valid);
        $display("mem_data.ready: %d",
            mem_intf.cb.mem_data.ready);

        $display("\nmem_req:");
        $display("mem_req.addr: %h",mem_intf.cb.mem_req.addr);
        $display("mem_req.data: %h",mem_intf.cb.mem_req.data);
        $display("mem_req.rw  : %h",mem_intf.cb.mem_req.rw);
        $display("cpu_res.data: %h",cache_out_intf.cb_out.cpu_res.data);
        $display("--- End tmp output-----\n");
    endtask : temp_output
endclass
