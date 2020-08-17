`include "param_def.v"

package ModExp_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import inp_pkg::*;
  import men_in_pkg::*;
  import outp_pkg::*;

  // typedef struct packed {
    // bit[2:0] len;
    // bit[1:0] prio;
    // bit en;
    // bit[7:0] avail;
  // } mcdf_reg_t;

  // typedef enum {RW_LEN, RW_PRIO, RW_EN, RD_AVAIL} mcdf_field_t;

  class ModExp_refmod extends uvm_component;//改
    local virtual ModExp_intf intf;
    mcdf_reg_t regs[3];

    uvm_blocking_get_port #(reg_trans) reg_bg_port;
    uvm_blocking_get_peek_port #(mon_data_t) in_bgpk_ports[3];

    uvm_tlm_fifo #(fmt_trans) out_tlm_fifos[3];

    `uvm_component_utils(ModExp_refmod)

    function new (string name = "ModExp_refmod", uvm_component parent);
      super.new(name, parent);
      reg_bg_port = new("reg_bg_port", this);
      foreach(in_bgpk_ports[i]) in_bgpk_ports[i] = new($sformatf("in_bgpk_ports[%0d]", i), this);
      foreach(out_tlm_fifos[i]) out_tlm_fifos[i] = new($sformatf("out_tlm_fifos[%0d]", i), this);
    endfunction

    task run_phase(uvm_phase phase);
      fork
        do_reset();
        this.do_reg_update();
        do_packet(0);
        do_packet(1);
        do_packet(2);
      join
    endtask

    class BN;
      rand bit [127:0] num [32:0];
      string name;

      constraint c {num[32]==0;num[0][0]==1;};

      function new(string name="A");
        this.name = name;
      endfunction
      
    endclass : BN

    // BN display
    function void BN_display(bit flag=0);
        string s;
        s={s,name,":"};
        if(flag==1)
        s={s,$sformatf("%h",num[32])};
        for (int i=1; i<32+1; i++) begin
        s={s,$sformatf("%h",num[32-i])};
        end
        s={s,"\n"};
        $display(s);
    endfunction : BN_display
	
	// BN_shift
    function void BN_shift();
      for (int i=0; i<32; i++) begin
        num[i] = num[i+1];
      end
      num[32] = 0;
    endfunction : BN_shift
	
	// BN_mul
    function void BN_mul(bit [127:0] a,BN ans);
        bit [255:0] temp;
        bit [127:0] carry;
      for (int i = 0; i < 32; i++)
      begin
          temp = num[i] * a + carry;
          ans.num[i] = temp[127:0];
          carry = temp>>128;
      end
      ans.num[32] = carry;
    endfunction : BN_mul
	
	  // BN_add
    function automatic void BN_add(input BN a,b,ref BN c);
      bit [128:0] psum;
      bit carry;
      carry =0;
        for (int i = 0; i < 32+1; i++)
        begin
          psum = a.num[i] + b.num[i]+ carry;
          c.num[i] = psum;
          carry = psum[128];
        end
    endfunction : BN_add
	
	    // BN_com
    function void BN_com(ref BN c);
      BN temp,b;
      temp = new("temp");
      b = new("b");
      for (int i=0; i<32+1; i++) begin
        temp.num[i]=~this.num[i];
        b.num[i]=0;
      end
      b.num[0]=1;
      BN_add(temp,b,c);
    endfunction : BN_com
	
  // BN_sub
    function automatic void BN_sub(input BN a,b,ref BN c);
      BN com;
      com =new("com");
      b.BN_com(com);
      BN_add(a,com,c);
    endfunction : BN_sub
	
	//              BN_w
    function void BN_w(output bit [127:0] w);
        bit[127:0] t;
        bit[255:0] tt;
        t=1;
        tt=0;
        for (int i=0; i<127; i++) begin
                tt=t*t;
                t=tt[127:0];
                tt=t*num[0];
                t=tt[127:0];
                $display("%h",t);
        end
        tt=0-t;
        w=tt[127:0];
    endfunction
	
	//              BN_cmp return 1 when this >= a
    function bit BN_cmp(input BN a);
        for (int i=0; i<32+1; i++) begin
                if(num[32-i]<a.num[32-i])
                        return 0;
                if(num[32-i]>a.num[32-i])
                        return 1;
        end
        return 1;
    endfunction
	
	  // BN_sub
  function automatic void mont_mul(input BN x,y,N,ref BN r);
        BN temp1,temp2,temp3;
        bit [127:0] u,w;
        bit [255:0] ut;
        temp1=new("temp1");
        temp2=new("temp2");
        temp3=new("temp3");
        N.BN_w(w);
        $display("%h",w);
        x.BN_display();
        y.BN_display();
        N.BN_display();
        r.BN_display();
        for (int i=0; i<32; i++) begin
                ut=y.num[i]*x.num[0];
                u=ut[127:0];
                ut=r.num[0]+u;
                u=ut[127:0];
                ut=u*w;
                u=ut[127:0];
                x.BN_mul(y.num[i], temp1);
                N.BN_mul(u, temp2);
                BN_add(r, temp1, temp3);
                BN_add(temp3, temp2, r);
                r.BN_shift();
        end
        if(r.BN_cmp(N)) begin
                BN_sub(r,N,temp1);
                r.num=temp1.num;
        end
        $display("x*y*p^-1 mod N:");
        r.BN_display();
  endfunction : mont_mul


    task do_reg_update();
      reg_trans t;
      forever begin
        this.reg_bg_port.get(t);
        if(t.addr[7:4] == 0 && t.cmd == `WRITE) begin
          this.regs[t.addr[3:2]].en = t.data[0];
          this.regs[t.addr[3:2]].prio = t.data[2:1];
          this.regs[t.addr[3:2]].len = t.data[5:3];
        end
        else if(t.addr[7:4] == 1 && t.cmd == `READ) begin
          this.regs[t.addr[3:2]].avail = t.data[7:0];
        end
      end
    endtask

    task do_packet(int id);
      fmt_trans ot;
      mon_data_t it;
      forever begin
        this.in_bgpk_ports[id].peek(it);
        ot = new();
        ot.length = 4 << (this.get_field_value(id, RW_LEN) & 'b11);
        ot.data = new[ot.length];
        ot.ch_id = id;
        foreach(ot.data[m]) begin
          this.in_bgpk_ports[id].get(it);
          ot.data[m] = it.data;
        end
        this.out_tlm_fifos[id].put(ot);
      end
    endtask

    function int get_field_value(int id, mcdf_field_t f);
      case(f)
        RW_LEN: return regs[id].len;
        RW_PRIO: return regs[id].prio;
        RW_EN: return regs[id].en;
        RD_AVAIL: return regs[id].avail;
      endcase
    endfunction 

    task do_reset();
      forever begin
        @(negedge intf.rstn); 
        foreach(regs[i]) begin
          regs[i].len = 'h0;
          regs[i].prio = 'h3;
          regs[i].en = 'h1;
          regs[i].avail = 'h20;
        end
      end
    endtask

    function void set_interface(virtual mcdf_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction
  endclass: ModExp_refmod

  // ModExp checker (scoreboard)

  `uvm_blocking_put_imp_decl(_t)
  `uvm_blocking_put_imp_decl(_r)
  `uvm_blocking_put_imp_decl(_d)
  `uvm_blocking_put_imp_decl(_n0)
  `uvm_blocking_put_imp_decl(_n)
  `uvm_blocking_put_imp_decl(_inp)
  `uvm_blocking_put_imp_decl(_outp)  

  // `uvm_blocking_get_peek_imp_decl(_chnl0)
  // `uvm_blocking_get_peek_imp_decl(_chnl1)
  // `uvm_blocking_get_peek_imp_decl(_chnl2)

  // `uvm_blocking_get_imp_decl(_reg)
   
  class ModExp_checker extends uvm_scoreboard;
    local int err_count;
    local int total_count;
    local virtual mem_in_intf t_vif; 
    local virtual mem_in_intf r_vif; 	
    local virtual mem_in_intf d_vif; 	 
    local virtual mem_in_intf n_vif; 	
    local virtual outp_intf outp_vif;	
    local virtual inp_intf inp_vif;
    local virtual ModExp_intf ModExp_vif;
    local ModExp_refmod refmod;

    uvm_blocking_put_imp_t    #(mon_data_t, ModExp_checker)   t_bp_imp;
    uvm_blocking_put_imp_r    #(mon_data_t, ModExp_checker)   r_bp_imp;
    uvm_blocking_put_imp_d    #(mon_data_t, ModExp_checker)   d_bp_imp;
    uvm_blocking_put_imp_n0   #(inp_trans,  ModExp_checker)   n0_bp_imp;
    uvm_blocking_put_imp_n    #(mon_data_t, ModExp_checker)   n_bp_imp;
    uvm_blocking_put_imp_inp  #(inp_trans , ModExp_checker)   inp_bp_imp;	
    uvm_blocking_put_imp_outp #(outp_trans, ModExp_checker)   outp_bp_imp;
	

    // uvm_blocking_get_peek_imp_chnl0 #(mon_data_t, mcdf_checker)  chnl0_bgpk_imp;
    // uvm_blocking_get_peek_imp_chnl1 #(mon_data_t, mcdf_checker)  chnl1_bgpk_imp;
    // uvm_blocking_get_peek_imp_chnl2 #(mon_data_t, mcdf_checker)  chnl2_bgpk_imp;

    // uvm_blocking_get_imp_reg    #(reg_trans , mcdf_checker)  reg_bg_imp  ;

    // mailbox #(mon_data_t) chnl_mbs[3];
    // mailbox #(fmt_trans)  fmt_mb;
    // mailbox #(reg_trans)  reg_mb;

 //   uvm_blocking_get_port #(fmt_trans) exp_bg_ports[3];

    `uvm_component_utils(ModExp_checker)

    function new (string name = "ModExp_checker", uvm_component parent);
      super.new(name, parent);
      this.err_count = 0;
      this.total_count = 0;
      t_bp_imp = new("t_bp_imp", this);
      r_bp_imp = new("r_bp_imp", this);
      d_bp_imp = new("d_bp_imp", this);
      n0_bp_imp   = new("n0_bp_imp", this);  
      n_bp_imp   = new("n_bp_imp", this);  
      inp_bp_imp = new("inp_bp_imp", this);
      outp_bp_imp = new("outp_bp_imp", this);
    endfunction

    function void build_phase(uvm_phase phase);//暂定
      super.build_phase(phase);
      this.refmod = ModExp_refmod::type_id::create("refmod", this);
    endfunction

    function void connect_phase(uvm_phase phase);//暂定
      super.connect_phase(phase);
      refmod.in_bgpk_ports[0].connect(chnl0_bgpk_imp);
      refmod.in_bgpk_ports[1].connect(chnl1_bgpk_imp);
      refmod.in_bgpk_ports[2].connect(chnl2_bgpk_imp);

      refmod.reg_bg_port.connect(reg_bg_imp);

      foreach(exp_bg_ports[i]) begin
        exp_bg_ports[i].connect(refmod.out_tlm_fifos[i].blocking_get_export);
      end
    endfunction

    function void set_interface(virtual ModExp_intf ModExp_vif, virtual chnl_intf chnl_vifs[3], virtual arb_intf arb_vif);//暂定
      if(ModExp_vif == null)
        $error("ModExp interface handle is NULL, please check if target interface has been intantiated");
      else begin
        this.ModExp_vif = ModExp_vif;
        this.refmod.set_interface(ModExp_vif);
      end
      if(chnl_vifs[0] == null || chnl_vifs[1] == null || chnl_vifs[2] == null)
        $error("chnl interface handle is NULL, please check if target interface has been intantiated");
      else begin
        this.chnl_vifs = chnl_vifs;
      end
      if(arb_vif == null)
        $error("arb interface handle is NULL, please check if target interface has been intantiated");
      else begin
        this.arb_vif = arb_vif;
      end
    endfunction

    task run_phase(uvm_phase phase);
      fork
        this.do_channel_disable_check(0);
        this.do_channel_disable_check(1);
        this.do_channel_disable_check(2);
        this.do_arbiter_priority_check();
        this.do_data_compare();
        this.refmod.run();
      join
    endtask

    task do_data_compare();
      fmt_trans expt, mont;
      bit cmp;
      forever begin
        this.fmt_mb.get(mont);
        this.exp_bg_ports[mont.ch_id].get(expt);
        cmp = mont.compare(expt);   
        this.total_count++;
        this.chnl_count[mont.ch_id]++;
        if(cmp == 0) begin
          this.err_count++;
          `uvm_error("[CMPERR]", $sformatf("%0dth times comparing but failed! MCDF monitored output packet is different with reference model output", this.total_count))
        end
        else begin
          `uvm_info("[CMPSUC]",$sformatf("%0dth times comparing and succeeded! MCDF monitored output packet is the same with reference model output", this.total_count), UVM_LOW)
        end
      end
    endtask

    task do_channel_disable_check(int id);
      forever begin
        @(posedge this.mcdf_vif.clk iff (this.mcdf_vif.rstn && this.mcdf_vif.mon_ck.chnl_en[id]===0));
        if(this.chnl_vifs[id].mon_ck.ch_valid===1 && this.chnl_vifs[id].mon_ck.ch_ready===1)
          `uvm_error("[CHKERR]", "ERROR! when channel disabled, ready signal raised when valid high") 
      end
    endtask

    task do_arbiter_priority_check();
      int id;
      forever begin
        @(posedge this.arb_vif.clk iff (this.arb_vif.rstn && this.arb_vif.mon_ck.f2a_id_req===1));
        id = this.get_slave_id_with_prio();
        if(id >= 0) begin
          @(posedge this.arb_vif.clk);
          if(this.arb_vif.mon_ck.a2s_acks[id] !== 1)
            `uvm_error("[CHKERR]", $sformatf("ERROR! arbiter received f2a_id_req===1 and channel[%0d] raising request with high priority, but is not granted by arbiter", id))
        end
      end
    endtask

    function int get_slave_id_with_prio();
      int id=-1;
      int prio=999;
      foreach(this.arb_vif.mon_ck.slv_prios[i]) begin
        if(this.arb_vif.mon_ck.slv_prios[i] < prio && this.arb_vif.mon_ck.slv_reqs[i]===1) begin
          id = i;
          prio = this.arb_vif.mon_ck.slv_prios[i];
        end
      end
      return id;
    endfunction

    function void report_phase(uvm_phase phase);
      string s;
      super.report_phase(phase);
      s = "\n---------------------------------------------------------------\n";
      s = {s, "CHECKER SUMMARY \n"}; 
      s = {s, $sformatf("total comparison count: %0d \n", this.total_count)}; 
      foreach(this.chnl_count[i]) s = {s, $sformatf(" channel[%0d] comparison count: %0d \n", i, this.chnl_count[i])};
      s = {s, $sformatf("total error count: %0d \n", this.err_count)}; 
      foreach(this.chnl_mbs[i]) begin
        if(this.chnl_mbs[i].num() != 0)
          s = {s, $sformatf("WARNING:: chnl_mbs[%0d] is not empty! size = %0d \n", i, this.chnl_mbs[i].num())}; 
      end
      if(this.fmt_mb.num() != 0)
          s = {s, $sformatf("WARNING:: fmt_mb is not empty! size = %0d \n", this.fmt_mb.num())}; 
      s = {s, "---------------------------------------------------------------\n"};
      `uvm_info(get_type_name(), s, UVM_LOW)
    endfunction

    task put_chnl0(mon_data_t t);
      chnl_mbs[0].put(t);
    endtask
    task put_chnl1(mon_data_t t);
      chnl_mbs[1].put(t);
    endtask
    task put_chnl2(mon_data_t t);
      chnl_mbs[2].put(t);
    endtask
    task put_fmt(fmt_trans t);
      fmt_mb.put(t);
    endtask
    task put_reg(reg_trans t);
      reg_mb.put(t);
    endtask
    task peek_chnl0(output mon_data_t t);
      chnl_mbs[0].peek(t);
    endtask
    task peek_chnl1(output mon_data_t t);
      chnl_mbs[1].peek(t);
    endtask
    task peek_chnl2(output mon_data_t t);
      chnl_mbs[2].peek(t);
    endtask
    task get_chnl0(output mon_data_t t);
      chnl_mbs[0].get(t);
    endtask
    task get_chnl1(output mon_data_t t);
      chnl_mbs[1].get(t);
    endtask
    task get_chnl2(output mon_data_t t);
      chnl_mbs[2].get(t);
    endtask
    task get_reg(output reg_trans t);
      reg_mb.get(t);
    endtask
  endclass: mcdf_checker

  class ModExp_coverage extends uvm_component;//存在问题，前面对应模块的修改还有注意mem_in是五个
    local virtual mem_in_intf mem_in_n_vif; 
    local virtual mem_in_intf mem_in_t_vif;	
    local virtual mem_in_intf mem_in_r_vif;	
    local virtual mem_in_intf mem_in_d_vif;	
//    local virtual mem_in_intf mem_in_n0_vifs;
	
    local virtual outp_intf outp_vif; 
    local virtual inp_intf inp_vif;
	local virtual ModExp_intf ModExp_vif;

    `uvm_component_utils(ModExp_coverage)

    covergroup cg_modexp_mem_n_write_read;
       waddr: coverpoint mem_in_n_vifs.mon_ck.waddr[4:0] {
	     bins avail[] = {0, 1, [2:7], [8:16], [17:28], 29, 30, 31}	   
/*       waddr: coverpoint mem_in_vifs.mon_ck.waddr {//根据结果改仓
        bins waddr_0   = {0} ;
        bins waddr_2   = {2} ;
        bins waddr_3   = {3} ;
        bins waddr_4   = {4} ;
        bins waddr_5   = {5} ;
        bins waddr_6   = {6} ;
        bins waddr_7   = {7} ;
        bins waddr_8   = {8} ;
        bins waddr_9   = {9} ;
        bins waddr_10  = {10};
        bins waddr_11  = {11};
        bins waddr_12  = {12};
        bins waddr_13  = {13};
        bins waddr_14  = {14};
        bins waddr_16  = {16};
        bins waddr_17  = {17};
        bins waddr_18  = {18};
		bins misc = default;*/
      } 
      raddr: coverpoint mem_in_n_vifs.mon_ck.raddr[4:0] {
	    bins avail[] = {0, 1, [2:7], [8:16], [17:28], 29, 30, 31}
	  
/*         type_option.weight = 0;
         bins addr_0   = {0} ;
         bins addr_1   = {1} ;
         bins addr_2   = {2} ;
         bins addr_3   = {3} ;
         bins addr_4   = {4} ;
         bins addr_5   = {5} ;
         bins addr_6   = {6} ;
         bins addr_7   = {7} ;
         bins addr_8   = {8} ;
         bins addr_9   = {9} ;
         bins addr_10  = {10};
         bins addr_11  = {11};
         bins addr_12  = {12};
         bins addr_13  = {13};
         bins addr_14  = {14};
         bins addr_16  = {16};
         bins addr_17  = {17};
         bins addr_18  = {18};
		 bins misc = default; */
      } 
    endgroup: cg_modexp_mem_n_write_read
	
    covergroup cg_modexp_mem_t_write_read;
       waddr: coverpoint mem_in_t_vifs.mon_ck.waddr[4:0] {
	     bins avail[] = {0, 1, [2:7], [8:16], [17:28], 29, 30, 31}	   
      } 
      raddr: coverpoint mem_in_t_vifs.mon_ck.raddr[4:0] {
	    bins avail[] = {0, 1, [2:7], [8:16], [17:28], 29, 30, 31}
      } 
    endgroup: cg_modexp_mem_t_write_read

    covergroup cg_modexp_mem_r_write_read;
       waddr: coverpoint mem_in_r_vifs.mon_ck.waddr[4:0] {
	     bins avail[] = {0, 1, [2:7], [8:16], [17:28], 29, 30, 31}	   
      } 
      raddr: coverpoint mem_in_r_vifs.mon_ck.raddr[4:0] {
	    bins avail[] = {0, 1, [2:7], [8:16], [17:28], 29, 30, 31}
      } 
    endgroup: cg_modexp_mem_r_write_read

    covergroup cg_modexp_mem_d_write_read;
       waddr: coverpoint mem_in_d_vifs.mon_ck.waddr[4:0] {
	     bins avail[] = {0, 1, [2:7], [8:16], [17:28], 29, 30, 31}	   
      } 
      raddr: coverpoint mem_in_d_vifs.mon_ck.raddr[4:0] {
	    bins avail[] = {0, 1, [2:7], [8:16], [17:28], 29, 30, 31}
      } 
    endgroup: cg_modexp_mem_d_write_read	

    covergroup cg_modexp_mem_n_illegal;
      waddr: coverpoint mem_in_n_vifs.mon_ck.waddr {
        type_option.weight = 0;
        bins legal_w = {[0:32'b1]};//对不对这步
        bins illegal = default;
      }
      raddr: coverpoint mem_in_n_vifs.mon_ck.raddr {
        type_option.weight = 0;
        bins legal_w = {[0:32'b1]};//对不对这步
        bins illegal = default;
      }
      wdata: coverpoint mem_in_n_vifs.mon_ck.data_in {//前面读写使能需要改
        type_option.weight = 0;
        bins legal = {[0:'h3F]};//位宽不确定
        bins illegal = {['h40:$]};//位宽不确定
      }
     rdata: coverpoint mem_in_n_vifs.mon_ck.data_out {
        type_option.weight = 0;
		bins legal = {[0:'h3F] };//位宽不确定  binsofe
        bins illegal = {['h40:$]};//位宽不确定
      }	  
      wren: coverpoint mem_in_n_vifs.mon_ck.wren {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  rden: coverpoint mem_in_n_vifs.mon_ck.rden {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  //chiwanfanhuilaikankanzenmejiaocha
      waddrwdata: cross  wren, waddr, wdata// {
       /*  bins addr_legal_rw = binsof(addr.legal_rw);
        bins addr_legal_r = binsof(addr.legal_r);
        bins addr_illegal = binsof(addr.illegal);
        bins cmd_write = binsof(cmd.write);
        bins cmd_read = binsof(cmd.read);
        bins wdata_legal = binsof(wdata.legal);
        bins wdata_illegal = binsof(wdata.illegal);
        bins rdata_legal = binsof(rdata.legal);
        bins write_illegal_addr = binsof(cmd.write) && binsof(addr.illegal);
        bins read_illegal_addr  = binsof(cmd.read) && binsof(addr.illegal);
        bins write_illegal_rw_data = binsof(cmd.write) && binsof(addr.legal_rw) && binsof(wdata.illegal);
        bins write_illegal_r_data = binsof(cmd.write) && binsof(addr.legal_r) && binsof(wdata.illegal); */
    //  }
	   raddrrdata: cross  rden, raddr, rdata
    endgroup:cg_modexp_mem_n_illegal
	
    covergroup cg_modexp_mem_t_illegal;
      waddr: coverpoint mem_in_t_vifs.mon_ck.waddr {
        type_option.weight = 0;
        bins legal_w = {[0:32'b1]};//对不对这步
        bins illegal = default;
      }
      raddr: coverpoint mem_in_t_vifs.mon_ck.raddr {
        type_option.weight = 0;
        bins legal_w = {[0:32'b1]};//对不对这步
        bins illegal = default;
      }
      wdata: coverpoint mem_in_t_vifs.mon_ck.data_in {//前面读写使能需要改
        type_option.weight = 0;
        bins legal = {[0:'h3F]};//位宽不确定
        bins illegal = {['h40:$]};//位宽不确定
      }
     rdata: coverpoint mem_in_t_vifs.mon_ck.data_out {
        type_option.weight = 0;
		bins legal = {[0:'h3F] };//位宽不确定  binsofe
        bins illegal = {['h40:$]};//位宽不确定
      }	  
      wren: coverpoint mem_in_t_vifs.mon_ck.wren {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  rden: coverpoint mem_in_t_vifs.mon_ck.rden {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  //chiwanfanhuilaikankanzenmejiaocha
      waddrwdata: cross  wren, waddr, wdata{
	  
	  
	  }
	  raddrrdata: cross  rden, raddr, rdata{
	  
	  
	  
	  
	  }
    endgroup:cg_modexp_mem_t_illegal	
	
    covergroup cg_modexp_mem_r_illegal;
      waddr: coverpoint mem_in_r_vifs.mon_ck.waddr {
        type_option.weight = 0;
        bins legal_w = {[0:32'b1]};//对不对这步
        bins illegal = default;
      }
      raddr: coverpoint mem_in_r_vifs.mon_ck.raddr {
        type_option.weight = 0;
        bins legal_w = {[0:32'b1]};//对不对这步
        bins illegal = default;
      }
      wdata: coverpoint mem_in_r_vifs.mon_ck.data_in {//前面读写使能需要改
        type_option.weight = 0;
        bins legal = {[0:'h3F]};//位宽不确定
        bins illegal = {['h40:$]};//位宽不确定
      }
     rdata: coverpoint mem_in_r_vifs.mon_ck.data_out {
        type_option.weight = 0;
		bins legal = {[0:'h3F] };//位宽不确定  binsofe
        bins illegal = {['h40:$]};//位宽不确定
      }	  
      wren: coverpoint mem_in_r_vifs.mon_ck.wren {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  rden: coverpoint mem_in_r_vifs.mon_ck.rden {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  //chiwanfanhuilaikankanzenmejiaocha
      waddrwdata: cross  wren, waddr, wdata{
	  
	  
	  }
	  raddrrdata: cross  rden, raddr, rdata{
	  
	  
	  
	  
	  }
    endgroup:cg_modexp_mem_r_illegal	
	
    covergroup cg_modexp_mem_d_illegal;
      waddr: coverpoint mem_in_d_vifs.mon_ck.waddr {
        type_option.weight = 0;
        bins legal_w = {[0:32'b1]};//对不对这步
        bins illegal = default;
      }
      raddr: coverpoint mem_in_d_vifs.mon_ck.raddr {
        type_option.weight = 0;
        bins legal_w = {[0:32'b1]};//对不对这步
        bins illegal = default;
      }
      wdata: coverpoint mem_in_d_vifs.mon_ck.data_in {//前面读写使能需要改
        type_option.weight = 0;
        bins legal = {[0:'h3F]};//位宽不确定
        bins illegal = {['h40:$]};//位宽不确定
      }
     rdata: coverpoint mem_in_d_vifs.mon_ck.data_out {
        type_option.weight = 0;
		bins legal = {[0:'h3F] };//位宽不确定  binsofe
        bins illegal = {['h40:$]};//位宽不确定
      }	  
      wren: coverpoint mem_in_d_vifs.mon_ck.wren {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  rden: coverpoint mem_in_d_vifs.mon_ck.rden {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  //chiwanfanhuilaikankanzenmejiaocha
      waddrwdata: cross  wren, waddr, wdata{
	  
	  
	  }
	  raddrrdata: cross  rden, raddr, rdata{
	  
	  
	  
	  
	  }
    endgroup:cg_modexp_mem_d_illegal	
	    
    covergroup cg_inp;
      startInput: coverpoint inp_vif.mon_ck.startInput {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
      startCompute: coverpoint inp_vif.mon_ck.startCompute {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  getResult: coverpoint inp_vif.mon_ck.getResult {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  inp: coverpoint inp_vif.mon_ck.inp {
        type_option.weight = 0;
	  } 
    endgroup

    covergroup cg_outp;
      stateModExp: coverpoint outp_vif.mon_ck.stateModExp {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  stateModExpSub: coverpoint outp_vif.mon_ck.stateModExpSub {
        type_option.weight = 0;
        wildcard bins en  = {1'b1};
        wildcard bins dis = {1'b0};
      }
	  outp: coverpoint outp_vif.mon_ck.outp {
        type_option.weight = 0;       
		
		
              }
    endgroup

    function new (string name = "ModExp_coverage", uvm_component parent);
      super.new(name, parent);
      this.cg_modexp_mem_n_write_read = new();
      this.cg_modexp_mem_n_illegal = new();
      this.cg_modexp_mem_t_write_read = new();
      this.cg_modexp_mem_t_illegal = new();	  
      this.cg_modexp_mem_r_write_read = new();
      this.cg_modexp_mem_r_illegal = new();	  
      this.cg_modexp_mem_d_write_read = new();
      this.cg_modexp_mem_d_illegal = new();	    
      this.cg_inp = new();
      this.cg_outp = new();
    endfunction

    task run_phase(uvm_phase phase);
      fork 
        this.do_mem_sample();
        this.do_inp_sample();
        this.do_outp_sample();
      join
    endtask

    task do_mem_sample();//取样时是否需要特定条件才能取？？？？？？？？
      forever begin
        @(posedge ModExp_intf.clk iff ModExp_intf.rstn);//这个是用哪个是时钟
        this.cg_modexp_mem_write_read.sample();
        this.cg_modexp_mem_illegal.sample();
      end
    endtask

    task do_inp_sample();
      forever begin
        @(posedge inp_vif.clk iff inp_vif.rstn);
        this.do_inp_sample.sample();
      end
    endtask

    task do_outp_sample();
      forever begin
        @(posedge outp_vif.clk iff outp_vif.rstn);
          this.cg_outp.sample();
      end
    endtask

    function void report_phase(uvm_phase phase);
      string s;
      super.report_phase(phase);
      s = "\n---------------------------------------------------------------\n";
      s = {s, "COVERAGE SUMMARY \n"}; 
      s = {s, $sformatf("total coverage: %.1f \n", $get_coverage())}; 
      s = {s, $sformatf("  cg_modexp_mem_n_write_read coverage: %.1f \n", this.cg_modexp_mem_n_write_read.get_coverage())}; 
      s = {s, $sformatf("  cg_modexp_mem_t_write_read coverage: %.1f \n", this.cg_modexp_mem_t_write_read.get_coverage())};
      s = {s, $sformatf("  cg_modexp_mem_r_write_read coverage: %.1f \n", this.cg_modexp_mem_r_write_read.get_coverage())};
      s = {s, $sformatf("  cg_modexp_mem_d_write_read coverage: %.1f \n", this.cg_modexp_mem_d_write_read.get_coverage())};
      s = {s, $sformatf("  cg_modexp_mem_n_illegal coverage: %.1f \n", this.cg_modexp_mem_n_illegal.get_coverage())}; 
      s = {s, $sformatf("  cg_modexp_mem_t_illegal coverage: %.1f \n", this.cg_modexp_mem_t_illegal.get_coverage())};
      s = {s, $sformatf("  cg_modexp_mem_r_illegal coverage: %.1f \n", this.cg_modexp_mem_r_illegal.get_coverage())};
      s = {s, $sformatf("  cg_modexp_mem_d_illegal coverage: %.1f \n", this.cg_modexp_mem_d_illegal.get_coverage())};
      s = {s, $sformatf("  cg_inp coverage: %.1f \n", this.cg_inp.get_coverage())}; 
      s = {s, $sformatf("  cg_outp coverage: %.1f \n", this.cg_outp.get_coverage())}; 
      s = {s, "---------------------------------------------------------------\n"};
      `uvm_info(get_type_name(), s, UVM_LOW)
    endfunction

    virtual function void set_interface(virtual mem_in_intf mem_in_n_vif
                                        ,virtual mem_in_intf mem_in_t_vif
                                        ,virtual mem_in_intf mem_in_r_vif
                                        ,virtual mem_in_intf mem_in_d_vif 										
                                        ,virtual outp_intf outp_vif
                                        ,virtual inp_intf inp_vif
                                        ,virtual ModExp_intf ModExp_vif
                                      );
      this.mem_in_n_vif = mem_in_n_vif;
      this.mem_in_t_vif = mem_in_t_vif;
      this.mem_in_r_vif = mem_in_r_vif;
      this.mem_in_d_vif = mem_in_d_vif;
	  
      this.outp_vif = outp_vif;
      this.inp_vif = inp_vif;
      this.ModExp_intf = ModExp_vif;
      if(mem_in_n_vif == null || mem_in_t_vif == null || mem_in_r_vif == null || mem_in_d_vif == null)
        $error("mem_in interface handle is NULL, please check if target interface has been intantiated");
      if(outp_vif == null)
        $error("outp interface handle is NULL, please check if target interface has been intantiated");
      if(inp_vif == null)
        $error("inp interface handle is NULL, please check if target interface has been intantiated");
      if(ModExp_vif == null)
        $error("ModExp interface handle is NULL, please check if target interface has been intantiated");
    endfunction
	
  endclass: ModExp_coverage

  class ModExp_virtual_sequencer extends uvm_sequencer;
    inp_sequencer inp_sqr;
    mem_in_sequencer mem_in_t_sqr;
    mem_in_sequencer mem_in_r_sqr;
    mem_in_sequencer mem_in_d_sqr;
//    mem_in_sequencer mem_in_n0_sqr;
    mem_in_sequencer mem_in_n_sqr;
 	
    `uvm_component_utils(ModExp_virtual_sequencer)
    function new (string name = "ModExp_virtual_sequencer", uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass:ModExp_virtual_sequencer

  class ModExp_env extends uvm_env;
    inp_agent inp_agt;
    mem_in_agent t_agt;
    mem_in_agent r_agt;
    mem_in_agent d_agt;
    mem_in_agent n_agt;	
    outp_agent outp_agt;
    ModExp_checker chker;
    ModExp_coverage cvrg;

    ModExp_virtual_sequencer virt_sqr;

    `uvm_component_utils(ModExp_env)

    function new (string name = "ModExp_env", uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      this.chker    = ModExp_checker::type_id::create("chker", this);
      this.inp_agt  = inp_agent::type_id::create("inp_agt", this);	  
      this.t_agt    = mem_in_agent::type_id::create("t_agt", this);
      this.r_agt    = mem_in_agent::type_id::create("r_agt", this);
      this.d_agt    = mem_in_agent::type_id::create("d_agt", this);
      this.n0_agt   = mem_in_agent::type_id::create("n0_agt", this);
      this.n_agt    = mem_in_agent::type_id::create("n_agt", this);
      this.outp_agt = outp_agent::type_id::create("outp_agt", this);
      this.cvrg     = ModExp_coverage::type_id::create("cvrg", this);	  
	  
      this.virt_sqr = ModExp_virtual_sequencer::type_id::create("virt_sqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);//改右边
      super.connect_phase(phase);

      inp_agt.monitor.mon_bp_port.connect(chker.inp_bp_imp);//c and n0
      t_agt.monitor.mon_bp_port.connect(chker.t_bp_imp);
      r_agt.monitor.mon_bp_port.connect(chker.r_bp_imp);
      d_agt.monitor.mon_bp_port.connect(chker.d_bp_imp);
      n_agt.monitor.mon_bp_port.connect(chker.n_bp_imp);	
      outp_agt.monitor.mon_bp_port.connect(chker.outp_bp_imp);	  
	  
      virt_sqr.inp_sqr = inp_agt.sequencer;//c and n0
      virt_sqr.t_sqr = t_agt.sequencer;
      virt_sqr.r_sqr = r_agt.sequencer;
      virt_sqr.d_sqr = d_agt.sequencer;
      virt_sqr.n_sqr = n_agt.sequencer;
    endfunction
  endclass: ModExp_env

  class ModExp_base_virtual_sequence extends uvm_sequence;
    inp_data_sequence inp_data_seq;
    mem_in_sequence mem_t_seq;
    mem_in_sequence mem_r_seq;
    mem_in_sequence mem_d_seq;	
    mem_in_sequence mem_n0_seq;
    mem_in_sequence mem_n_seq;
	

    `uvm_object_utils(ModExp_base_virtual_sequence)
    `uvm_declare_p_sequencer(ModExp_virtual_sequencer)

    function new (string name = "ModExp_base_virtual_sequence");
      super.new(name);
    endfunction

    virtual task body();
      `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
      this.do_reg();
      this.do_formatter();
      this.do_data();
      `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
    endtask

    // do register configuration
    virtual task do_reg();
      //User to implment the task in the child virtual sequence
    endtask

    // do external formatter down stream slave configuration
    virtual task do_formatter();
      //User to implment the task in the child virtual sequence
    endtask

    // do data transition from 3 channel slaves
    virtual task do_data();
      //User to implment the task in the child virtual sequence
    endtask

    virtual function bit diff_value(int val1, int val2, string id = "value_compare");
      if(val1 != val2) begin
        `uvm_error("[CMPERR]", $sformatf("ERROR! %s val1 %8x != val2 %8x", id, val1, val2)) 
        return 0;
      end
      else begin
        `uvm_info("[CMPSUC]", $sformatf("SUCCESS! %s val1 %8x == val2 %8x", id, val1, val2), UVM_LOW)
        return 1;
      end
    endfunction
  endclass:ModExp_base_virtual_sequence

  class ModExp_base_test extends uvm_test;
    ModExp_env env;
    virtual inp_intf inp_vif;
    virtual men_in_intf t_vif;
    virtual men_in_intf r_vif;
    virtual men_in_intf d_vif;
    virtual men_in_intf n0_vif;
    virtual men_in_intf n_vif;
    virtual outp_intf outp_vif;
    virtual ModExp_intf ModExp_vif;

    `uvm_component_utils(ModExp_base_test)

    function new(string name = "ModExp_base_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // get virtual interface from top TB
      if(!uvm_config_db#(virtual inp_intf)::get(this,"","inp_vif", inp_vif)) begin
        `uvm_fatal("GETVIF","cannot get vif handle from config DB")
      end
      if(!uvm_config_db#(virtual men_in_intf)::get(this,"","t_vif", t_vif)) begin
        `uvm_fatal("GETVIF","cannot get vif handle from config DB")
      end
      if(!uvm_config_db#(virtual men_in_intf)::get(this,"","r_vif", r_vif)) begin
        `uvm_fatal("GETVIF","cannot get vif handle from config DB")
      end
      if(!uvm_config_db#(virtual men_in_intf)::get(this,"","d_vif", d_vif)) begin
        `uvm_fatal("GETVIF","cannot get vif handle from config DB")
      end
      if(!uvm_config_db#(virtual men_in_intf)::get(this,"","n0_vif", n0_vif)) begin
        `uvm_fatal("GETVIF","cannot get vif handle from config DB")
      end
      if(!uvm_config_db#(virtual men_in_intf)::get(this,"","n_vif", n_vif)) begin
        `uvm_fatal("GETVIF","cannot get vif handle from config DB")
      end
      if(!uvm_config_db#(virtual outp_intf)::get(this,"","outp_vif", outp_vif)) begin
        `uvm_fatal("GETVIF","cannot get vif handle from config DB")
      end	  
      if(!uvm_config_db#(virtual ModExp_intf)::get(this,"","ModExp_vif", ModExp_vif)) begin
        `uvm_fatal("GETVIF","cannot get vif handle from config DB")
      end

      this.env = ModExp_env::type_id::create("env", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      this.set_interface(inp_vif, t_vif, r_vif, d_vif, n0_vif, n_vif, outp_vif, ModExp_vif);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      uvm_root::get().set_report_verbosity_level_hier(UVM_HIGH);
      uvm_root::get().set_report_max_quit_count(1);
      uvm_root::get().set_timeout(50ms);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      this.run_top_virtual_sequence();
      phase.drop_objection(this);
    endtask

    virtual task run_top_virtual_sequence();
      // User to implement this task in the child tests
    endtask

    virtual function void set_interface(virtual inp_intf inp_vif 
                                        ,virtual men_in_intf t_vif 
                                        ,virtual men_in_intf r_vif 
                                        ,virtual men_in_intf d_vif
                                        ,virtual men_in_intf n0_vif
                                        ,virtual men_in_intf n_vif
										,virtual outp_intf outp_vif
                                        ,virtual ModExp_intf ModExp_vif
                                      );
      this.env.inp_agt.set_interface(inp_vif);
      this.env.t_agt.set_interface(t_vif);
      this.env.r_agt.set_interface(r_vif);
      this.env.d_agt.set_interface(d_vif);
      this.env.n0_agt.set_interface(n0_vif);
      this.env.n_agt.set_interface(n_vif);
      this.env.outp_agt.set_interface(outp_vif);
	  
	  //可能要加
	  //改
      //this.env.chker.set_interface(mcdf_vif, '{ch0_vif, ch1_vif, ch2_vif}, arb_vif);
      //this.env.cvrg.set_interface('{ch0_vif, ch1_vif, ch2_vif}, reg_vif, arb_vif, fmt_vif, mcdf_vif);
    endfunction
  endclass: ModExp_base_test

  class ModExp_data_consistence_basic_virtual_sequence extends ModExp_base_virtual_sequence;//改
    `uvm_object_utils(ModExp_data_consistence_basic_virtual_sequence)
    function new (string name = "ModExp_data_consistence_basic_virtual_sequence");
      super.new(name);
    endfunction
	
    task do_reg();
      bit[31:0] wr_val, rd_val;
      // slv0 with len=8,  prio=0, en=1
      wr_val = (1<<3)+(0<<1)+1;
      `uvm_do_on_with(write_reg_seq, p_sequencer.reg_sqr, {addr == `SLV0_RW_ADDR; data == wr_val;})
      `uvm_do_on_with(read_reg_seq, p_sequencer.reg_sqr, {addr == `SLV0_RW_ADDR;})
      rd_val = read_reg_seq.data;
      void'(this.diff_value(wr_val, rd_val, "SLV0_WR_REG"));

      // slv1 with len=16, prio=1, en=1
      wr_val = (2<<3)+(1<<1)+1;
      `uvm_do_on_with(write_reg_seq, p_sequencer.reg_sqr, {addr == `SLV1_RW_ADDR; data == wr_val;})
      `uvm_do_on_with(read_reg_seq, p_sequencer.reg_sqr, {addr == `SLV1_RW_ADDR;})
      rd_val = read_reg_seq.data;
      void'(this.diff_value(wr_val, rd_val, "SLV1_WR_REG"));

      // slv2 with len=32, prio=2, en=1
      wr_val = (3<<3)+(2<<1)+1;
      `uvm_do_on_with(write_reg_seq, p_sequencer.reg_sqr, {addr == `SLV2_RW_ADDR; data == wr_val;})
      `uvm_do_on_with(read_reg_seq, p_sequencer.reg_sqr, {addr == `SLV2_RW_ADDR;})
      rd_val = read_reg_seq.data;
      void'(this.diff_value(wr_val, rd_val, "SLV2_WR_REG"));

      // send IDLE command
      `uvm_do_on(idle_reg_seq, p_sequencer.reg_sqr)
    endtask
    task do_formatter();
      `uvm_do_on_with(fmt_config_seq, p_sequencer.fmt_sqr, {fifo == LONG_FIFO; bandwidth == HIGH_WIDTH;})
    endtask
    task do_data();
      fork
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[0], {ntrans==100; ch_id==0; data_nidles==0; pkt_nidles==1; data_size==8; })
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[1], {ntrans==100; ch_id==1; data_nidles==1; pkt_nidles==4; data_size==16;})
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[2], {ntrans==100; ch_id==2; data_nidles==2; pkt_nidles==8; data_size==32;})
      join
      #10us; // wait until all data haven been transfered through MCDF
    endtask
  endclass: ModExp_data_consistence_basic_virtual_sequence

  class ModExp_data_consistence_basic_test extends ModExp_base_test;

    `uvm_component_utils(ModExp_data_consistence_basic_test)

    function new(string name = "ModExp_data_consistence_basic_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_top_virtual_sequence();
      ModExp_data_consistence_basic_virtual_sequence top_seq = new();
      top_seq.start(env.virt_sqr);
    endtask
  endclass: ModExp_data_consistence_basic_test

  class mcdf_full_random_virtual_sequence extends mcdf_base_virtual_sequence;
    `uvm_object_utils(mcdf_base_virtual_sequence)
    function new (string name = "mcdf_base_virtual_sequence");
      super.new(name);
    endfunction

    task do_reg();
      bit[31:0] wr_val, rd_val;
      // slv0 with len={4,8,16,32},  prio={[0:3]}, en={[0:1]}
      wr_val = ($urandom_range(0,3)<<3)+($urandom_range(0,3)<<1)+$urandom_range(0,1);
      `uvm_do_on_with(write_reg_seq, p_sequencer.reg_sqr, {addr == `SLV0_RW_ADDR; data == wr_val;})
      `uvm_do_on_with(read_reg_seq, p_sequencer.reg_sqr, {addr == `SLV0_RW_ADDR;})
      rd_val = read_reg_seq.data;
      void'(this.diff_value(wr_val, rd_val, "SLV0_WR_REG"));

      // slv0 with len={4,8,16,32},  prio={[0:3]}, en={[0:1]}
      wr_val = ($urandom_range(0,3)<<3)+($urandom_range(0,3)<<1)+$urandom_range(0,1);
      `uvm_do_on_with(write_reg_seq, p_sequencer.reg_sqr, {addr == `SLV1_RW_ADDR; data == wr_val;})
      `uvm_do_on_with(read_reg_seq, p_sequencer.reg_sqr, {addr == `SLV1_RW_ADDR;})
      rd_val = read_reg_seq.data;
      void'(this.diff_value(wr_val, rd_val, "SLV1_WR_REG"));

      // slv0 with len={4,8,16,32},  prio={[0:3]}, en={[0:1]}
      wr_val = ($urandom_range(0,3)<<3)+($urandom_range(0,3)<<1)+$urandom_range(0,1);
      `uvm_do_on_with(write_reg_seq, p_sequencer.reg_sqr, {addr == `SLV2_RW_ADDR; data == wr_val;})
      `uvm_do_on_with(read_reg_seq, p_sequencer.reg_sqr, {addr == `SLV2_RW_ADDR;})
      rd_val = read_reg_seq.data;
      void'(this.diff_value(wr_val, rd_val, "SLV2_WR_REG"));

      // send IDLE command
      `uvm_do_on(idle_reg_seq, p_sequencer.reg_sqr)
    endtask
    task do_formatter();
      `uvm_do_on_with(fmt_config_seq, p_sequencer.fmt_sqr, {fifo inside {SHORT_FIFO, ULTRA_FIFO}; bandwidth inside {LOW_WIDTH, ULTRA_WIDTH};})
    endtask
    task do_data();
      fork
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[0], 
          {ntrans inside {[400:600]}; ch_id==0; data_nidles inside {[0:3]}; pkt_nidles inside {1,2,4,8}; data_size inside {8,16,32};})
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[1], 
          {ntrans inside {[400:600]}; ch_id==0; data_nidles inside {[0:3]}; pkt_nidles inside {1,2,4,8}; data_size inside {8,16,32};})
        `uvm_do_on_with(chnl_data_seq, p_sequencer.chnl_sqrs[2], 
          {ntrans inside {[400:600]}; ch_id==0; data_nidles inside {[0:3]}; pkt_nidles inside {1,2,4,8}; data_size inside {8,16,32};})
      join
      #10us; // wait until all data haven been transfered through MCDF
    endtask
  endclass: mcdf_full_random_virtual_sequence

  class mcdf_full_random_test extends mcdf_base_test;

    `uvm_component_utils(mcdf_full_random_test)

    function new(string name = "mcdf_full_random_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_top_virtual_sequence();
      mcdf_full_random_virtual_sequence top_seq = new();
      top_seq.start(env.virt_sqr);
    endtask
  endclass: mcdf_full_random_test

endpackage
