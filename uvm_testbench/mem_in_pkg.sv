`include "_parameter.v"

package men_in_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  typedef enum {LONG,SHORT} dw_t;

  class dat1;			//n0
    rand int data_t [`DATA_WIDTH32];
    bit data;

    constraint c {
      foreach (data_t[i]) data_t[i]<1'hf;
      foreach (data_t[i]) data_t[i]>'0;//条件不对
    };

    function void post_randomize();
      foreach(data_t[i]) begin
        this.data[i*4+:4]=data_t[i];//感觉按照n0.txt,是32*4位，此处可以理解为16进制转2进制么
      end
    endfunction
  endclass : dat1
//按照设计是64x32 64个字每个32位，

  class dat2;
    rand int data_t [`DATA_WIDTH32];//这感觉是64
    bit [`TOTAL_ADDR32-1:0] data;//data 是2048

    constraint c {
      foreach (data_t[i]) data_t[i]<5;
      foreach (data_t[i]) data_t[i]>-5;//?范围
    };

    function void post_randomize();
      foreach(data_t[i]) begin
        this.data[i*32+:32]=data_t[i];
      end
    endfunction
  endclass : dat2

  class mem_in_item extends uvm_sequence_item;
    rand bit dat_short [];
    rand bit [`TOTAL_ADDR32-1:0] dat_long [];
    bit rsp;
    rand dw_t dw;

    `uvm_object_utils_begin(mem_in_item)
      `uvm_field_enum(dw_t, dw, UVM_ALL_ON)
      `uvm_field_array_int(dat_short, UVM_ALL_ON)
      `uvm_field_array_int(dat_long, UVM_ALL_ON)
    `uvm_object_utils_end

    function new (string name = "mem_in_item");
      super.new(name);
    endfunction

    function void post_randomize();
      dat1 data1;
      dat2 data2;
      data1=new();
      data2=new();
      if (this.dw==LONG) begin
        foreach(dat_long[i]) begin
            void'(data2.randomize());
            dat_long[i]=data2.data;
        end
      end else begin
        foreach(dat_short[i]) begin
            void'(data1.randomize());
            dat_short[i]=data1.data;
        end
      end
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
        intf.dat_s_in <= '0;
        intf.dat_l_in <= '0;
		intf.wren  <= '0;
		intf.rden  <= '0;
      end
    endtask

    task do_drive();
      mem_in_item req, rsp;
      // bit [511:0] mem_l [];
      // bit [255:0] mem_s [];
      //string s;
      @(posedge intf.rstn);
      forever begin
        seq_item_port.get_next_item(req);
		this.mem_write(req);
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        rsp.set_sequence_id(req.get_sequence_id());
        seq_item_port.item_done(rsp);
        //s={get_full_name(),".txt"};
        // if(req.dw==LONG) begin
          // mem_l=req.dat_long;
          // $writememh(s,mem_l);
        // end else begin
          // mem_s=req.dat_short;
          // $writememh(s,mem_s);
        end
	endtask
	
	task mem_write(mem_in_item t);
      @(posedge intf.clk iff intf.rstn);
        if(wren && (!rden))
          if(req.dw==LONG) begin
            intf.dat_l_in <= t.dat_long;//前面没改但是感觉data_long有点问题
          end else begin
            intf.dat_s_in <= t.dat_short;//[intf.waddr];
          end
		else if(rden && (!wren))
          if(req.dw==LONG) begin
             t.dat_long<= intf.dat_l_out;//[intf.raddr];
          end else begin
		     t.dat_short<= intf.dat_s_out;
          end
          if(!intf.rst_n) begin
            break;
    endtask
  endclass

  class mem_in_sequencer extends uvm_sequencer #(mem_in_item);
    `uvm_component_utils(mem_in_sequencer)
    function new (string name = "mem_in_sequencer", uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass: mem_in_sequencer

  class mem_in_base_sequence extends uvm_sequence #(mem_in_item);//往后未修改
    rand int mem_length;
    rand dw_t dw;

    `uvm_object_utils_begin(mem_in_base_sequence)
      `uvm_field_int(mem_length, UVM_ALL_ON)
      `uvm_field_enum(dw_t,dw, UVM_ALL_ON)
    `uvm_object_utils_end
    `uvm_declare_p_sequencer(mem_in_sequencer)

    function new (string name = "mem_in_base_sequence");
      super.new(name);
    endfunction

    task body();
      send_trans();
    endtask

    task send_trans();
      mem_in_item req, rsp;
      string s;
      $display("this.dw:%s",this.dw);
      if (this.dw==LONG) begin
      `uvm_do_with(req, {dw == LONG;
                         dat_short.size() == 0;
                         dat_long.size() == mem_length;
                         })
      end else begin
      `uvm_do_with(req, {dw == SHORT;
                         dat_long.size() == 0;
                         dat_short.size() == mem_length;
                         })
      end
      `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
      get_response(rsp);
      `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
      assert(rsp.rsp)
        else $error("[RSPERR] %0t error response received!", $time);
    endtask
  endclass: mem_in_base_sequence

  // typedef struct packed {
    // bit[255:0] data;
    // bit[15:0] addr;
  // } mon_in_data_short_t;

  // typedef struct packed {
    // bit[511:0] data;
    // bit[15:0] addr;
  // } mon_in_data_long_t;

  class mem_in_monitor extends uvm_monitor;
    local virtual mem_in_intf intf;
    dw_t dw;
    // uvm_blocking_put_port #(mon_in_data_short_t) mon_bp_port_short;
    // uvm_blocking_put_port #(mon_in_data_long_t) mon_bp_port_long;//??????????

    `uvm_component_utils(mem_in_monitor)

    function new(string name="mem_in_monitor", uvm_component parent);
      super.new(name, parent);
      // mon_bp_port_short = new("mon_bp_port_short", this);
      // mon_bp_port_long = new("mon_bp_port_long", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(dw_t)::get(this,"","dw", dw)) begin//？？？？配置文件怎么运行
        `uvm_fatal("GET DW","cannot get DW from config DB")
      end
    endfunction

    function void set_interface(virtual mem_in_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task run_phase(uvm_phase phase);
      case (dw)
      LONG:     mon_trans_long();
      SHORT:    mon_trans_short();
      default:  $error("command %s is illegal", dw);
      endcase
    endtask

    task mon_trans_short();
      forever begin
        @(posedge intf.clk iff intf.mon_ck.rd_en);
        fork
          mon_short_single();
        join_none
      end
    endtask

    task mon_short_single();
      mon_in_data_short_t m;
      m.addr = intf.mon_ck.addr;//这个地址是所以还是写
      @(posedge intf.clk);
      m.data = intf.mon_ck.dat_s;
      mon_bp_port_short.put(m);//?????????????????????????????
      `uvm_info(get_type_name(), $sformatf("monitored mem data 'h%x mem addr 'd%d", m.data,m.addr), UVM_FULL)
    endtask : mon_short_single

    task mon_trans_long();
      forever begin
        @(posedge intf.clk iff intf.mon_ck.rd_en);
        fork
          mon_long_single();
        join_none
      end
    endtask : mon_trans_long

    task mon_long_single();
      mon_in_data_long_t m;
      m.addr = intf.mon_ck.addr;
      @(posedge intf.clk);
      m.data = intf.mon_ck.dat_l;
      mon_bp_port_long.put(m);
      `uvm_info(get_type_name(), $sformatf("monitored mem data 'h%x mem addr 'd%d", m.data,m.addr), UVM_FULL)
    endtask : mon_long_single

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
      driver.seq_item_port.connect(sequencer.seq_item_export);//??????????????????????
    endfunction

    function void set_interface(virtual men_in_intf vif);
      this.vif = vif;
      driver.set_interface(vif);
      monitor.set_interface(vif);
    endfunction
  endclass: men_in_agent

endpackage
