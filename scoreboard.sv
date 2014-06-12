class scoreboard;
    mailbox dr2sb;
    mailbox rc2sb_cpu;
    mailbox rc2sb_mem;

    function new(   mailbox dr2sb,
                    mailbox rc2sb_cpu,
                    mailbox rc2sb_mem);
        this.dr2sb = dr2sb;
        this.rc2sb_cpu = rc2sb_cpu;
        this.rc2sb_mem = rc2sb_mem;
    endfunction : new

    task start();
        packet pkt_drv;
        receiver_pack pkt_rcv;
        int dr_flag, rc_flag;

        forever begin
            dr2sb.get(pkt_drv);
            $display("%0d: Scoreboard: Received a packet from driver",$time);
            while(1) begin
                rc2sb_mem.get(pkt_rcv);
                 $display
                    ("%0d: Scoreboard: Received a packet from receiver",$time);
                $display("Type: %s", pkt_rcv.rcvr_type);
                if(int'(pkt_rcv.rcvr_type) == 2)
                    break;
            end
            //rc2sb_mem.get()
            //dr_flag = dr2sb.try_get(pkt_drv);
            //if(dr_flag) begin
                //dr2sb.get(pkt_drv);
                // while(1) begin
                //     if(rc2sb_mem.num()!=0) begin
                //         rc2sb_mem.get(pkt_rcv);

                //         if(pkt_rcv.compare(pkt_drv)) begin
                //             $display("%0d: Scoreboard: Packet Matched",$time);
                //         end
                //         else begin
                //             error++;
                //         end

                //         if(int'(pkt_rcv.rcvr_type) == 2)
                //             break;
                //     end
                // end
            //end
	    end
    endtask : start

endclass
