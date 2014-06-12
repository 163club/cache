class driver;
    //virtual cpu_req_type cpu_req;
    //cpu_req_type cpu_req;
    //virtual mem_data_type mem_data;
    virtual cache_interface.CACHE_IN cache_intf;
    mailbox dr2sb;
    packet data_pkt;

    /// constructor ///
    function new(   virtual cache_interface.CACHE_IN cache_intf,
                    mailbox dr2sb);
        this.cache_intf = cache_intf;
        if(dr2sb == null) begin
            $display("***ERROR***: Driver to scorboard is null.");
            $finish;
        end
        else
            this.dr2sb = dr2sb;
        data_pkt = new();
    endfunction : new

    /// method to send packet to DUT ///
    task start();
      packet pkt;

      repeat(num_of_pkts) begin
        repeat(2) @(posedge cache_intf.clock);
        pkt = new data_pkt;
        //$display ("%0d : Driver : Before randmoization, packet:.",$time);

        if(pkt.randomize()) begin
           $display ("%0d : Driver : Randomization Successesfull.",$time);
           //pkt.display();
           /// Drive pkg valid == 1
           pkt.valid = 1;
           //// display the packet content ///////
           pkt.display();

         // begin
         //   @(posedge cache_intf.clock);
              cache_intf.cb_in.cpu_req <= pkt.cpu_req_pack();
         // end
          // deassert valid signal
          begin
            @(posedge cache_intf.clock);
              pkt.valid = 0;
              cache_intf.cb_in.cpu_req <= pkt.cpu_req_pack();
          end


           //// Pack the packet in tp stream of bytes //////
           // length = pkt.byte_pack(bytes);

           // ///// assert the data_status signal and send the packed bytes //////
           // foreach(bytes[i])
           // begin
           //    @(posedge input_intf.clock);
           //    input_intf.cb.data_status <= 1;
           //    input_intf.cb.data_in <= bytes[i];
           // end

           // //// deassert the data_status singal //////
           // @(posedge input_intf.clock);
           // input_intf.cb.data_status <= 0;
           // input_intf.cb.data_in <= 0;

           //// Push the packet in to mailbox for scoreboard /////
           dr2sb.put(pkt);

           $display("%0d : Driver : Finished Driving the packet", $time);
         end
         else
          begin
             $display ("%0d : Driver : ** Randomization failed. **",$time);
             ////// Increment the error count in randomization fails ////////
             error++;
          end
        repeat(8) @(posedge cache_intf.clock);
      end
    endtask : start

endclass