`include "_parameter.v"

package inp_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class inp_trans extends uvm_sequence_item;//改
    rand bit [`DATA_WIDTH-1:0]data;
	rand int data_nidles;
    rand bit [`DATA_WIDTH-1:0] n0_data//数据位宽
	// rand int pkt_nidles;
	bit rsp;
	
    constraint cstr{
	   data inside {[0:(`DATA_WIDTH32 - 1)]};
	   n0_data inside {[0:(`DATA_WIDTH32 - 1)]};

       soft data_nidles inside {[0:2]};
       // soft pkt_nidles inside {[1:10]};
    };
	
    `uvm_object_utils_begin(inp_trans)
      // `uvm_field_array_int(data, UVM_ALL_ON)
       `uvm_field_int(data, UVM_ALL_ON)
       `uvm_field_int(n0_data, UVM_ALL_ON)
       `uvm_field_int(data_nidles, UVM_ALL_ON)
       // `uvm_field_int(pkt_nidles, UVM_ALL_ON)
       `uvm_field_int(rsp, UVM_ALL_ON)
    `uvm_object_utils_end
	
    function new (string name = "inp_trans");
      super.new(name);
    endfunction
  endclass:inp_trans

  class inp_driver extends uvm_driver #(inp_trans);//改
    local virtual inp_intf intf;
	
    `uvm_component_utils(inp_driver)
  
    function new (string name = "inp_driver", uvm_component parent);
      super.new(name, parent);
    endfunction
  
    function void set_interface(virtual inp_intf intf);
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
        intf.startInput <= 0;
        intf.startCompute <= 0;
		intf.getResult <= 0;
		intf.inp <= 0;
		intf.n0_data <= 0;
      end
    endtask

    task do_drive();
      inp_trans req, rsp;
      @(posedge intf.rstn);
      forever begin
        seq_item_port.get_next_item(req);
        this.inp_write(req);
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        rsp.set_sequence_id(req.get_sequence_id());
        seq_item_port.item_done(rsp);
      end
    endtask
  
    task inp_write(input inp_trans t);
        @(posedge intf.clk);
        intf.drv_ck.startInput <= 1;
        intf.drv_ck.startCompute <= 1;	
        intf.drv_ck.getResult <= 1;		
        intf.drv_ck.inp <= t.data;
		intf.n0_data <= t.n0_data;
		
        // @(negedge intf.clk);
        // wait(intf.ch_ready === 'b1);
        
		`uvm_info(get_type_name(), $sformatf("sent data 'h%8x", t.data), UVM_HIGH)
        repeat(t.data_nidles) inp_idle();
    endtask
    
    task inp_idle();//???????????????????????????????????????????
      @(posedge intf.clk);
        intf.drv_ck.startInput <= 0;
		intf.drv_ck.inp <= 0;
		intf.drv_ck.n0_data <= 0;
    endtask
  endclass: inp_driver

  class inp_sequencer extends uvm_sequencer #(inp_trans);
    `uvm_component_utils(inp_sequencer)
    function new (string name = "inp_sequencer", uvm_component parent);
      super.new(name, parent);
    endfunction
   endclass:inp_sequencer
  
  class inp_data_sequence extends uvm_sequence #(inp_trans);//改
    rand int data_nidles = -1;
    rand int data_size = -1;
    rand int ntrans = 10;//?
	
    `uvm_object_utils_begin(inp_data_sequence)
      //`uvm_field_int(pkt_id, UVM_ALL_ON)
      //`uvm_field_int(ch_id, UVM_ALL_ON)
      `uvm_field_int(data_nidles, UVM_ALL_ON)
      //`uvm_field_int(pkt_nidles, UVM_ALL_ON)
      `uvm_field_int(data_size, UVM_ALL_ON)
      `uvm_field_int(ntrans, UVM_ALL_ON)
    `uvm_object_utils_end
    `uvm_declare_p_sequencer(inp_sequencer)
	
    function new (string name = "inp_data_sequence");
      super.new(name);
    endfunction

    task body();
      repeat(ntrans) send_trans();
    endtask

    task send_trans();
      inp_trans req, rsp;
      `uvm_do_with(req, {//local::ch_id >= 0 -> ch_id == local::ch_id; 
                         //local::pkt_id >= 0 -> pkt_id == local::pkt_id;
                         local::data_nidles >= 0 -> data_nidles == local::data_nidles;
                         //local::pkt_nidles >= 0 -> pkt_nidles == local::pkt_nidles;
                         local::data_size >0 -> data.size() == local::data_size; 
                         })
      //this.pkt_id++;
      `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
      get_response(rsp);
      `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
      assert(rsp.rsp)
        else $error("[RSPERR] %0t error response received!", $time);
    endtask

  endclass: inp_data_sequence

  class inp_monitor extends uvm_monitor;//改
    local virtual inp_intf intf;
    uvm_blocking_put_port #(inp_trans) mon_bp_port;

    `uvm_component_utils(inp_monitor)

    function new(string name="inp_monitor", uvm_component parent);
      super.new(name, parent);
      mon_bp_port = new("mon_bp_port", this);
    endfunction

    function void set_interface(virtual inp_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task run_phase(uvm_phase phase);
      this.mon_trans();
    endtask

    task mon_trans();//改
      inp_trans m;
      forever begin
        @(posedge intf.clk iff (intf.mon_ck.startInput==='b1 && intf.mon_ck.startCompute==='b1 && intf.mon_ck.getResult==='b1));
        m.data = intf.mon_ck.inp;
		m.n0_data = intf.mon_ck.n0_data;
        mon_bp_port.put(m);
        `uvm_info(get_type_name(), $sformatf("monitored channel data 'h%8x", m.data), UVM_HIGH)
      end
    endtask
  endclass: inp_monitor

  class inp_agent extends uvm_agent;
    inp_driver driver;
    inp_monitor monitor;
    inp_sequencer sequencer; 
    local virtual inp_if vif;	
  
    `uvm_component_utils(inp_agent)
	
    function new (string name = "inp_agent", uvm_component parent);
      super.new(name, parent);
    endfunction
	
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      driver = inp_driver::type_id::create("driver", this);
      monitor = inp_monitor::type_id::create("monitor", this);
      sequencer = inp_sequencer::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

    function void set_interface(virtual inp_intf vif);
      this.vif = vif;
      driver.set_interface(vif);
      monitor.set_interface(vif);
    endfunction
  endclass: inp_agent

endpackage
