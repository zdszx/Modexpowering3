`include "_parameter.v"

package outp_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // typedef enum {SHORT_FIFO, MED_FIFO, LONG_FIFO, ULTRA_FIFO} fmt_fifo_t;
  // typedef enum {LOW_WIDTH, MED_WIDTH, HIGH_WIDTH, ULTRA_WIDTH} fmt_bandwidth_t;

  typedef struct packed {
    bit[`DATA_WIDTH-1:0] data;
  } mon_data_t;

  class outp_monitor extends uvm_monitor;//改
    local virtual outp_intf intf;
    uvm_blocking_put_port #(mon_data_t) mon_bp_port;

    `uvm_component_utils(outp_monitor)

    function new(string name="outp_monitor", uvm_component parent);
      super.new(name, parent);
      mon_bp_port = new("mon_bp_port",this);
    endfunction
	
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    endfunction	

    function void set_interface(virtual outp_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task run_phase(uvm_phase phase);
      this.mon_trans();
    endtask

    task mon_trans();
      mon_data_t m;
      forever begin
        wait(intf.stateModExp == `TERMINAL);
        m.data = intf.outp;
        mon_bp_port.put(m);
        `uvm_info(get_type_name(), $sformatf("monitored output data 'h%x", m.data), UVM_FULL)
      end
    endtask
  endclass: outp_monitor

  class outp_agent extends uvm_agent;
    outp_monitor monitor;
    local virtual outp_intf vif;

    `uvm_component_utils(outp_agent)

    function new(string name = "outp_agent", uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      monitor = outp_monitor::type_id::create("monitor", this);
    endfunction

    function void set_interface(virtual outp_intf vif);
      this.vif = vif;
      monitor.set_interface(vif);
    endfunction
  endclass:outp_agent

endpackage
