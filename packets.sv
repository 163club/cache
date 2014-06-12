`ifndef PACKETS_SV
`define PACKETS_SV

class packet;
  //address fields
  rand bit [17:0] tag;
  rand bit [9:0]  index;
  rand bit [1:0]  block_offset;
  rand bit [1:0]  byte_offset;

  rand bit [31:0] data;
  rand bit rw;
  rand bit valid;

  bit [31:0] addr ={tag, index, block_offset, byte_offset};
  // addr[31:14] = tag;
  // addr[13:4] = index;
  // addr[3:2] = block_offset;
  // addr[1:0] = byte_offset;

  // constraints
  constraint default_pkg { valid == 0 ;}

  // method to pack random cpu_req
  virtual function cpu_req_type cpu_req_pack();
    cpu_req_type cpu_req;
    bit [31:0] temp_addr;
    temp_addr[31:14] = tag;
    temp_addr[13:4] = index;
    temp_addr[3:2] = block_offset;
    temp_addr[1:0] = byte_offset;
    cpu_req.addr = temp_addr;
    cpu_req.data = data;
    cpu_req.rw = rw;
    cpu_req.valid = valid;
    return cpu_req;
  endfunction : cpu_req_pack

  // method to unpack cpu_req_type
  virtual function void cpu_req_unpack(const ref cpu_req_type cpu_req);
    this.tag = cpu_req.addr[31:14];
    this.index = cpu_req.addr[13:4];
    this.block_offset = cpu_req.addr[3:2];
    this.byte_offset = cpu_req.addr[1:0];
    this.data = cpu_req.data;
    this.rw = cpu_req.rw;
    this.valid = cpu_req.valid;
  endfunction:cpu_req_unpack

  //method to display packet
  virtual function void display();
    $display("\n---------- PACKET ---------- ");
    $display("tag:\t %h ",tag);
    $display("index:\t %d ",index);
    $display("block_offset:\t %h ",block_offset);
    $display("byte_offset:\t %h ",byte_offset);
    $display("data:\t %h ",data);
    $display("rw:\t %h ",rw);
    $display("valid:\t %h ",valid);
    $display("------------ END ------------ \n");
  endfunction : display

  virtual function bit compare(packet cpu_req);
    compare = 1;
    if(cpu_req == null) begin
      $display ("ERROR: cpu_req compare received null object");
      compare = 0;
    end
    else begin
      if(cpu_req.addr !== this.addr) begin
        $display("ERROR: cpu_req compare: address field did not match");
        compare = 0;
      end
      if(cpu_req.data !== this.data) begin
        $display("ERROR: cpu_req compare: data field did not match");
        compare = 0;
      end
      if(cpu_req.rw !== this. rw) begin
        $display("ERROR: cpu_req compare: rw field did not match");
        compare = 0;
      end
      if(cpu_req.valid !== this.valid) begin
        $display("ERROR: cpu_req compare: valid field did not match");
        compare = 0;
      end
    end
  endfunction : compare

endclass

class receiver_pack;
    typedef enum {MEM_REQ, MEM_DATA, CPU_RES} receiver_type;
    receiver_type rcvr_type;

    function new();
    endfunction : new

    virtual function void display();
    endfunction : display

    virtual function bit compare(packet pkt);
    endfunction : compare
endclass

class mem_req_pack extends receiver_pack;
    mem_req_type mem_req;
    function new(mem_req_type mem_req);
        super.new();
        this.mem_req = mem_req;
        this.rcvr_type = MEM_REQ;
    endfunction : new

    virtual function void display();
      $display("Receiver Type: %s",rcvr_type);
      $display("Address: %h",mem_req.addr);
      $display("Data: %h",mem_req.data);
      $display("R/W: %d",mem_req.rw);
      $display("Valid: %d",mem_req.valid);
    endfunction: display

    virtual function bit compare(packet pkt);
      compare = 1;
      if(pkt == null) begin
        $display("ERROR: pkt: received a null object!");
        compare = 0;
      end
      else begin
        if(pkt.addr !== this.mem_req.addr) begin
          $display(" Error: pkt: address field did not match");
          compare = 0;
        end
        if(mem_req.rw) begin
          if(pkt.data !== this.mem_req.addr[32*pkt.block_offset+32]) begin
            $display("Error: pkt: data field did not match");
            compare = 0;
          end
	end
      end
    endfunction // compare

endclass

class mem_data_pack extends receiver_pack;
    mem_data_type mem_data;
    function new(mem_data_type mem_data);
        super.new();
        this.mem_data = mem_data;
        this.rcvr_type = MEM_DATA;
    endfunction : new

    virtual function void display();
      $display("Receiver Type: %s",rcvr_type);
      $display("Data: %h",mem_data.data);
      $display("Ready: %d",mem_data.ready);
    endfunction: display

   virtual  function bit compare(packet pkt);
      compare = 1;
      $display("Matched with %s",rcvr_type);
   endfunction: compare

endclass

class cpu_result_pack extends receiver_pack;
    cpu_result_type cpu_res;
    function new(cpu_result_type cpu_res);
        super.new();
        this.cpu_res = cpu_res;
        this.rcvr_type = CPU_RES;
    endfunction : new

    virtual function void display();
      $display("Receiver Type: %s",rcvr_type);
      $display("Data: %h",cpu_res.data);
      $display("Ready: %d",cpu_res.ready);
    endfunction: display

   virtual  function bit compare(packet pkt);
      compare = 1;
      $display("matched with %s",rcvr_type);
   endfunction: compare
endclass

`endif
