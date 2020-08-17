`include "_parameter.v"

package men_in_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class mem_in_item extends uvm_sequence_item;
    rand bit [4:0] addr;
	rand bit[63:0] data;
//  rand bit[31:0] data[];
    bit rsp;
    
    constraint cstr {
      soft data inside {32'0:32'b1}//这定义成8位16进制还是32位二进制 
	  soft addr inside {64'0:64'b1}
    };	
	
/*     constraint cstr {
       soft data.size == 64;
      foreach(data[i]) data[i] inside {[32'0:32'b1]}  
    };	 */
		
	
    `uvm_object_utils_begin(mem_in_item)
      `uvm_field_enum(addr, UVM_ALL_ON)
      `uvm_field_array_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new (string name = "mem_in_item");
      super.new(name);
    endfunction

  endclass : mem_in_item

  class mem_in_driver extends uvm_driver #(mem_in_item);
    local virtual mem_in_intf intf;

    `uvm_component_utils(mem_in_driver)

    function new (string name = "mem_in_driver", uvm_component parent);
      super.new(name, parent);
    endfunction

    function void set_interface(virtual mem_in_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task run_phase(uvm_phase phase);
      fork
        this.do_drive();
        this.do_reset();
      join
    endtask

    task do_reset();
      forever begin
        @(negedge intf.rstn);
		intf.waddr  <= '0;
		intf.data_in  <= '0;
      end
    endtask

    task do_drive();
      mem_in_item req, rsp;
      @(posedge intf.rstn);
      forever begin
        seq_item_port.get_next_item(req);
		this.mem_write(req);
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        rsp.set_sequence_id(req.get_sequence_id());
        seq_item_port.item_done(rsp);
        end
	endtask
	//????????????????????????????????????????????
	//????????????????????????????????????????????????
	task mem_write(mem_in_item t);//晚上顺序有点晕暂定
      @(posedge intf.clk iff intf.rstn);
        if(intf.wren && !intf.rden)begin
          intf.data_in <= t.data;
	      intf.waddr <= t.addr;
		end
		else if(!intf.wren && intf.rden)begin
          intf.data_out <= t.data;
	      intf.raddr <=t.addr;
        end
        if(!intf.rst_n)
          break;  
    endtask
  endclass

  class mem_in_sequencer extends uvm_sequencer #(mem_in_item);
    `uvm_component_utils(mem_in_sequencer)
    function new (string name = "mem_in_sequencer", uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass: mem_in_sequencer

  class mem_in_base_sequence extends uvm_sequence #(mem_in_item);
    rand bit [5:0] addr = -1;
	rand bit[31:0] data = -1;
	rand int ntrans = 32;

    constraint cstr{
      soft addr == -1;
      soft data == -1;
	  soft ntrans == //是32的整数倍
    }
	
	
    `uvm_object_utils_begin(mem_in_base_sequence)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end
    `uvm_declare_p_sequencer(mem_in_sequencer)

    function new (string name = "mem_in_base_sequence");
      super.new(name);
    endfunction

    task body();
      repeat(ntrans) send_trans();
    endtask

    task send_trans();
      mem_in_item req, rsp;
      `uvm_do_with(req, {local::addr >= 0 -> addr == local::addr;
                         local::data >= 0 -> data == local::data;
                         })
      `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
      get_response(rsp);
      `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
      assert(rsp.rsp)
        else $error("[RSPERR] %0t error response received!", $time);
    endtask
  endclass: mem_in_base_sequence

  class mem_in_monitor extends uvm_monitor;
    local virtual mem_in_intf intf;
    uvm_blocking_put_port #(mem_in_item) mon_bp_port;
    // uvm_blocking_put_port #(mon_in_data_long_t) mon_bp_port_long;//??????????

    `uvm_component_utils(mem_in_monitor)

    function new(string name="mem_in_monitor", uvm_component parent);
      super.new(name, parent);
      mon_bp_port = new("mon_bp_port", this);
    endfunction

    function void set_interface(virtual mem_in_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task run_phase(uvm_phase phase);
     this.mon_trans();
    endtask

    task mon_trans();
	  mem_in_item m;
      forever begin
        @(posedge intf.clk iff (intf.rstn);
		m = new();
		if (intf.mon_ck.wren == 'b1)begin
		  m.addr = intf.mon_ck.waddr;
		  m.data = intf.mon_ck.data_in;
		end
		else if (intf.mon_ck.rden == 'b1)begin
		  @(posedge intf.clk);
		  m.addr = intf.mon_ck.raddr;
		  m.data = intf.mon_ck.data_out;
		end
         mon_bp_port.put(m);
        `uvm_info(get_type_name(), $sformatf("addr %2x, cmd %2b, data %8x", m.addr, m.data), UVM_HIGH)
      end
    endtask

  endclass: mem_in_monitor
  
  class men_in_agent extends uvm_agent;
    men_in_driver driver;
    men_in_monitor monitor;
    men_in_sequencer sequencer;
    local virtual men_in_intf vif;

    `uvm_component_utils(men_in_agent)

    function new(string name = "men_in_agent", uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      driver = men_in_driver::type_id::create("driver", this);
      monitor = men_in_monitor::type_id::create("monitor", this);
      sequencer = men_in_sequencer::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

    function void set_interface(virtual men_in_intf vif);
      this.vif = vif;
      driver.set_interface(vif);
      monitor.set_interface(vif);
    endfunction
  endclass: men_in_agent

endpackage
