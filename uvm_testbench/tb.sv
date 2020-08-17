`timescale 1ns/1ps

`include "_parameter.v"

interface inp_intf(input clk, input rstn);//改
  logic startInput;
  logic startCompute;
  logic getResult;
  logic [`DATA_WIDTH-1:0]inp;
  logic n0_data;
  clocking drv_ck @(posedge clk);
    default input #1ns output #1ns;
    output startInput, startCompute, getResult, inp, n0_data;
  endclocking
  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input startInput, startCompute, getResult, inp, n0_data;
  endclocking
endinterface

interface mem_in_intf (input clk , input rstn);
  logic [4:0] raddr;
  logic [4:0] waddr;
  logic rden;
  logic wren;
  logic [`DATA_WIDTH-1:0] data_in;
  logic [`DATA_WIDTH-1:0] data_out;
  clocking drv_ck @(posedge clk);
    default input #1ns output #1ns;
    output data_in;
    input waddr,rden,wren,data_out, raddr;
  endclocking
  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input data_in,waddr,raddr,rden,wren,data_out;
  endclocking
endinterface

interface outp_intf(input clk, input rstn);//改
  logic [4 : 0] stateModExp;
  logic [2 : 0] stateModExpSub;
  logic [`DATA_WIDTH - 1 : 0] outp;
  logic [`DATA_WIDTH - 1 : 0] inpMonPro_data;
  logic [`DATA_WIDTH - 1 : 0] outpMonPro_data;
  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input stateModExp, stateModExpSub, outp, inpMonPro_data, outpMonPro_data;
  endclocking
endinterface

interface ModExp_intf(input clk, input rstn);//改

  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input ;
  endclocking
endinterface

module tb;
  logic         clk;
  logic         rstn;

ModExpPowering_3 dut(
	.clk					(clk),
	.reset					(rstn),
	.startInput				(inp_if.startInput),
	.startCompute			(inp_if.startCompute)	
	.getResult				(inp_if.getResult),	
	.c_wren					(),            //数据输入控制端口
	.n_wren					(store_n_if.wren),
	.r_wren					(store_r_if.wren),
	.t_wren					(store_t_if.wren),
	.waddr					(),
	.n0_in					(inp_if.n0_data),
	.d_in0					(store_d_if.data_in),
	.c_n_datain				(inp_if.inp),	           //数据输入				
	.r_t_datain				(store_n_if.data_in),
	.r_data_in				(store_r_if.data_in),
	.t_data_in				(store_t_if.data_in),		        //数据输入
	.inpMonPro_data			(outp_if.inpMonPro_data),      
	.outpMonPro_data		(outp_if.outpMonPro_data),
	.stateModExp			(outp_if.stateModExp),	                  //for MonExp
	.stateModExpSub			(outp_if.stateModExpSub),
	.outp					(outp_if.outp),
	.raddr					()

);
  
  // clock generation
  initial begin 
    clk <= 0;
    forever begin
      #5 clk <= !clk;
    end
  end
  
  // reset trigger
  initial begin 
    #10 rstn <= 0;
    repeat(10) @(posedge clk);
    rstn <= 1;
  end

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import inp_pkg::*;
  import men_in_pkg::*;
  import outp_pkg::*;
  import ModExp_pkg::*;

  inp_intf  inp_if(.*);
  men_in_intf store_t_if(.*);
  men_in_intf store_r_if(.*);
  men_in_intf store_d_if(.*);
  //men_in_intf store_n0_if(.*);
  men_in_intf store_n_if(.*);
  outp_intf outp_if(.*);
  ModExp_intf ModExp_if(.*);
  // 加上addr与rt....模块xianglian
  //haiyou data_out
  // ModExp interface monitoring ModExp ports and signals//改
  assign mem_in_intf.rden[0] = tb.dut.c_bram0.rden;
  assign mem_in_intf.rden[1] = tb.dut.n_bram0.rden;
  assign mem_in_intf.rden[2] = tb.dut.r_bram0.rden;
  assign mem_in_intf.rden[3] = tb.dut.t_bram0.rden;
  assign mem_in_intf.rden[4] = tb.dut.n_bram0.rden;
  
  assign mem_in_intf.raddr[0] = tb.dut.c_bram0.raddr;
  assign mem_in_intf.raddr[1] = tb.dut.n_bram0.raddr;
  assign mem_in_intf.raddr[2] = tb.dut.r_bram0.raddr;
  assign mem_in_intf.raddr[3] = tb.dut.t_bram0.raddr;
  assign mem_in_intf.raddr[4] = tb.dut.n_bram0.raddr;


  assign mem_in_intf.data_out[0] = tb.dut.c_bram0.data_out;
  assign mem_in_intf.data_out[1] = tb.dut.n_bram0.data_out;
  assign mem_in_intf.data_out[2] = tb.dut.r_bram0.data_out;
  assign mem_in_intf.data_out[3] = tb.dut.t_bram0.data_out;
  assign mem_in_intf.data_out[4] = tb.dut.n_bram0.data_out;
  // arbiter interface monitoring arbiter ports//改
  // assign arb_if.slv_prios[0] = tb.dut.arbiter_inst.slv0_prio_i;
  // assign arb_if.slv_prios[1] = tb.dut.arbiter_inst.slv1_prio_i;
  // assign arb_if.slv_prios[2] = tb.dut.arbiter_inst.slv2_prio_i;
  // assign arb_if.slv_reqs[0] = tb.dut.arbiter_inst.slv0_req_i;
  // assign arb_if.slv_reqs[1] = tb.dut.arbiter_inst.slv1_req_i;
  // assign arb_if.slv_reqs[2] = tb.dut.arbiter_inst.slv2_req_i;
  // assign arb_if.a2s_acks[0] = tb.dut.arbiter_inst.a2s0_ack_o;
  // assign arb_if.a2s_acks[1] = tb.dut.arbiter_inst.a2s1_ack_o;
  // assign arb_if.a2s_acks[2] = tb.dut.arbiter_inst.a2s2_ack_o;
  // assign arb_if.f2a_id_req = tb.dut.arbiter_inst.f2a_id_req_i;

  initial begin 
    // do interface configuration from top tb (HW) to verification env (SW)
    uvm_config_db#(virtual inp_intf)::set(uvm_root::get(), "uvm_test_top", "inp_vif", inp_if);	
    uvm_config_db#(virtual men_in_intf)::set(uvm_root::get(), "uvm_test_top", "mem_in_t_vif", store_t_if);
    uvm_config_db#(virtual men_in_intf)::set(uvm_root::get(), "uvm_test_top", "mem_in_r_vif", store_r_if);
    uvm_config_db#(virtual men_in_intf)::set(uvm_root::get(), "uvm_test_top", "mem_in_d_vif", store_d_if);
//    uvm_config_db#(virtual men_in_intf)::set(uvm_root::get(), "uvm_test_top", "mem_in_n0_vif", store_n0_if);
    uvm_config_db#(virtual men_in_intf)::set(uvm_root::get(), "uvm_test_top", "mem_in_n_vif", store_n_if);
    uvm_config_db#(virtual ModExp_intf)::set(uvm_root::get(), "uvm_test_top", "ModExp_vif", ModExp_if);
    // If no external configured via +UVM_TESTNAME=my_test, the default test is
    // mcdf_data_consistence_basic_test
    run_test("mcdf_data_consistence_basic_test");//改
  end
endmodule



