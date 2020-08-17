// MonPro module
// follow this algorithm: http://cs.ucsb.edu/~koc/cs290g/docs/w01/mon1.pdf
// ModExp follows my Master project slides
`include "_parameter.v"

module ModExpPowering_3	// c ^ d % n		c is the number, d is exponent, n is modulor
(
	input clk,
	input reset,
	input startInput,	       // tell FPGA to start input 
	input startCompute,	    // tell FPGA to start compute
	input getResult,	       // tell FPGA to output result
	input c_wren,            //数据输入控制端口
	input n_wren,
	input r_wren,
	input t_wren,
	input [4 : 0] waddr,
	input [`DATA_WIDTH - 1 : 0] n0_in,
	input [`DATA_WIDTH - 1 : 0] d_in0,
	input [`DATA_WIDTH - 1 : 0] c_n_datain,	           //数据输入				
	input [`DATA_WIDTH - 1 : 0] r_t_datain,		        //数据输入
	output [`DATA_WIDTH - 1 : 0] inpMonPro_data,      
	output [`DATA_WIDTH - 1 : 0] outpMonPro_data,
	output reg [4 : 0] stateModExp,	                  //for MonExp
	output reg [2 : 0] stateModExpSub,
	output reg [`DATA_WIDTH - 1 : 0] outp
);
/*
	reg [`DATA_WIDTH - 1 : 0] c_in [`TOTAL_ADDR - 1 : 0];	// for c input
	reg [`DATA_WIDTH - 1 : 0] r_in [`TOTAL_ADDR - 1 : 0];	// for r input
	reg [`DATA_WIDTH - 1 : 0] t_in [`TOTAL_ADDR - 1 : 0];	// for t input
*/
	reg [`DATA_WIDTH - 1 : 0] d_in [`TOTAL_ADDR - 1 : 0];	// for d input

	reg [`DATA_WIDTH - 1 : 0] c_bar [`TOTAL_ADDR - 1 : 0];	// multiple usage, to save regs
	reg [`DATA_WIDTH - 1 : 0] m_bar [`TOTAL_ADDR - 1 : 0];	// multiple usage, to save regs

	integer i;	// big loop i
	integer k_d1;
	integer k_d2;
	integer b;
	integer b2;
	
	reg startMonPro;
	reg [`DATA_WIDTH - 1 : 0] inpMonPro;
	wire [4 : 0] stateMonPro;
	wire [`DATA_WIDTH - 1 : 0] outpMonPro;
	reg rden;
	reg [4 : 0] raddr;
	reg [`DATA_WIDTH - 1 : 0] n_datain;
	b_ram c_bram0(
					.clock(clk),
					.data_in(c_n_datain),
					.waddr(waddr),
					.raddr(raddr),
					.rden(rden),
					.wren(m_wren),
					.data_out(c_data)
					);

	b_ram n_bram0(
					.clock(clk),
					.data_in(c_n_datain),
					.waddr(waddr),
					.raddr(raddr),
					.rden(n_rden),
					.wren(wren),
					.data_out(n_data)
					);
	b_ram r_bram0(
					.clock(clk),
					.data_in(r_t_datain),
					.waddr(waddr),
					.raddr(raddr),
					.rden(rden),
					.wren(r_wren),
					.data_out(r_data)
					);
	b_ram t_bram0(
					.clock(clk),
					.data_in(r_t_datain),
					.waddr(waddr),
					.raddr(raddr),
					.rden(rden),
					.wren(t_wren),
					.data_out(t_data)
					);		

	MonPro MonPro0 (
					.clk(clk), 
					.reset(reset),
					.start(startMonPro), 
					.inp(inpMonPro), 
					.n_data(n_datain),
					.n0_data(n0_in),
					.state(stateMonPro), 
					.outp(outpMonPro));

	
	
	assign inpMonPro_data = inpMonPro;
	assign outpMonPro_data = outpMonPro;
	always @ (posedge clk or posedge reset) begin
		if (reset) begin	
			i = 0;
			raddr = 0;
			stateModExpSub = `NOTASK;
			stateModExp = `NONE;
			k_d1 = `TOTAL_ADDR - 1;
			k_d2 = `DATA_WIDTH - 1;
		end
		else begin
			case (stateModExp)
				`NONE: 
				begin
					if(startInput)
						stateModExp = `LOADC;
				end

				`LOADC:	         //存入数据
				begin
					if(i <= `TOTAL_ADDR) begin
						d_in[i] = d_in0;
						i = i + 1;
					end
					else begin
						i = 0;
						stateModExp = `WAIT_COMPUTE;
					end
				end
							
				`WAIT_COMPUTE:
				begin
					if(startCompute) begin
						stateModExp = `CALC_C_BAR;
					end					
				end
				
				`CALC_C_BAR:	// 计算 c_bar = MonPro(c, t) 
				begin
					case (stateModExpSub)
						`NOTASK: 
						begin	
							startMonPro <= 1;
							stateModExpSub = `INP1;
						end
						
						`INP1 :          //把数据c_in存入monpro中
						begin
							inpMonPro <= c_data;
							n_datain <= n_data;
							raddr = raddr + 1;
							if(raddr == `TOTAL_ADDR) begin
								raddr = 0;
								stateModExpSub = `INP2;
							end
						end
						
						`INP2:
						begin
							if(raddr <= 0) begin		
								raddr = raddr + 1;
							end
							else begin
								inpMonPro <= t_data;
								raddr = raddr + 1;
								if(i > `TOTAL_ADDR) begin
									raddr = 0;
									stateModExpSub = `WAIT;
								end
							end
						end
						
						`WAIT:
						begin
							if(stateMonPro == `WRITEOUT) begin
								stateModExpSub = `OUTPINS;
							end
						end
						
						`OUTPINS:
						begin
							c_bar[raddr] <= outpMonPro;
							m_bar[raddr] <= r_data;
							raddr = raddr + 1;
							if(raddr == `TOTAL_ADDR) begin
								inpMonPro <= 64'h0000000000000000;
								raddr = 0;
								stateModExpSub = `NOTASK;
								stateModExp = `GET_K_D;
								startMonPro <= 0;
							end
						end
					endcase
				end
			
				`GET_K_D:	// a clock to initial the leftmost 1 in d = k_d
				begin
					if(d_in[k_d1][k_d2] == 1) begin
						$display("d_in[%d][%d] = %d", k_d1, k_d2, d_in[k_d1][k_d2]);
						stateModExp = `BIGLOOP;
					end
					else begin
						if(k_d2 == 0) begin
							k_d1 = k_d1 - 1;
							k_d2 = `DATA_WIDTH - 1;
						end
						else begin
							k_d2 = k_d2 - 1;
						end
					end
				end
			
				`BIGLOOP:	// for i = k_d1 * `DATA_WIDTH + k_d2 downto 0
				begin
					case (stateModExpSub)	// m_bar = MonPro(m_bar, m_bar)
						`NOTASK: 
						begin	
							b = 1 - d_in[k_d1][k_d2];
							b2 = d_in[k_d1][k_d2];
							startMonPro <= 1;
							stateModExpSub = `INP1;
						end
						
						`INP1:
						begin
							inpMonPro <= m_bar[raddr];
							raddr = raddr + 1;
							if(raddr == `TOTAL_ADDR) begin
								raddr = 0;
								stateModExpSub = `INP2;
							end
						end
						
						`INP2:
						begin
							if(raddr <= 0) begin		// need some delay here...
								raddr = raddr + 1;
							end
							else begin
								inpMonPro <= c_bar[raddr - 1];
								raddr = raddr + 1;
								if(raddr > `TOTAL_ADDR) begin
									raddr = 0;
									stateModExpSub = `WAIT;
								end
							end
						end
						
						`WAIT:
						begin
							if(stateMonPro == `WRITEOUT) begin
								stateModExpSub = `OUTPINS;
							end
						end
						
						`OUTPINS:
						begin
							if(b == 0) begin
								m_bar[raddr] <= outpMonPro;
							end
							else begin
								c_bar[raddr] <= outpMonPro;
							end
							raddr = raddr + 1;
							if(raddr == `TOTAL_ADDR) begin
								raddr = 0;
								inpMonPro <= 64'h0000000000000000;
								stateModExpSub = `NOTASK;
								startMonPro <= 0;
								$display("k_d1: %d, k_d2: %d", k_d1, k_d2);
								stateModExp = `CALC_SQUARE;	// go to R_b2 = MonPro(R_b2, R_b2)
							end
						end
					endcase
				end
				
				`CALC_SQUARE:	// R_b2 = MonPro(R_b2, R_b2)
				begin
					case (stateModExpSub)	
						`NOTASK: 
						begin
							startMonPro = 1;
							stateModExpSub = `INP1;
							raddr = 0;
						end
						
						`INP1:
						begin
							if(b2 == 0) begin
								inpMonPro <= m_bar[raddr];
							end
							else begin
								inpMonPro <= c_bar[raddr];
							end
							raddr = raddr + 1;
							if(raddr == `TOTAL_ADDR) begin
								raddr = 0;
								stateModExpSub = `INP2;
							end
						end
						
						`INP2:
						begin
							if(raddr <= 0) begin		// need some delay here...
								raddr = raddr + 1;
							end
							else begin
								if(b2 == 0) begin
									inpMonPro <= m_bar[raddr - 1];
								end
								else begin
									inpMonPro <= c_bar[raddr - 1];
								end
								raddr = raddr + 1;
								if(raddr > `TOTAL_ADDR) begin
									raddr = 0;
									stateModExpSub = `WAIT;
								end
							end
						end
						
						`WAIT:
						begin
							if(stateMonPro == `WRITEOUT) begin
								stateModExpSub = `OUTPINS;
							end
						end
						
						`OUTPINS:
						begin
							if(b2 == 0) begin
								m_bar[raddr] <= outpMonPro;
							end
							else begin
								c_bar[raddr] <= outpMonPro;
							end
							raddr= raddr + 1;
							if(raddr == `TOTAL_ADDR) begin
								raddr = 0;
								inpMonPro <= 64'h0000000000000000;
								stateModExpSub = `NOTASK;
								startMonPro <= 0;
								$display("k_d1: %d, k_d2: %d", k_d1, k_d2);
								if(k_d1 <= 0 && k_d2 <= 0)
									stateModExp = `CALC_M_BAR_1;
								else if(k_d2 == 0) begin	// down 1 of d
									k_d1 = k_d1 - 1;
									k_d2 = `DATA_WIDTH - 1;
									stateModExp = `BIGLOOP;
								end 
								else begin
									k_d2 = k_d2 - 1;
									stateModExp = `BIGLOOP;
								end
							end
						end
					endcase
				end		
	
				
				`CALC_M_BAR_1:	// m = MonPro(1, m_bar)
				begin
					case (stateModExpSub)	
						`NOTASK: 
						begin	
							startMonPro = 1;
							stateModExpSub = `INP1;
							raddr = 0;
						end
						
						`INP1:
						begin
							inpMonPro <= m_bar[raddr];
							raddr = raddr + 1;
							if(raddr == `TOTAL_ADDR) begin
								raddr = 0;
								stateModExpSub = `INP2;
							end
						end
						
						`INP2:
						begin
							if(raddr <= 0) begin		// need some delay here...
								raddr = raddr + 1;
							end
							else begin
								if(raddr == 1) begin
									inpMonPro <= 64'h00000000000000000000000000000001;
								end
								else begin
									inpMonPro <= 64'h0000000000000000;
								end
								raddr = raddr + 1;
								if(raddr > `TOTAL_ADDR) begin
									raddr = 0;
									stateModExpSub = `WAIT;
								end
							end
						end
						
						`WAIT:
						begin
							if(stateMonPro == `WRITEOUT) begin
								stateModExpSub = `OUTPINS;
							end
						end
						
						`OUTPINS:
						begin
							m_bar[raddr] <= outpMonPro;
							raddr = raddr + 1;
							if(raddr == `TOTAL_ADDR) begin
								raddr = 0;
								inpMonPro <= 64'h0000000000000000;
								stateModExpSub = `NOTASK;
								stateModExp = `COMPLETE;
								startMonPro <= 0;
							end
						end
					endcase	
				end
				
				`COMPLETE:	// Use a getResult signal to start this output
				begin
					if(getResult) begin
						stateModExp = `OUTPUT_RESULT;
					end				
				end
				
				`OUTPUT_RESULT:	// output 2048 bits result (m_bar) to output buffer!
				begin
					outp = m_bar[raddr];
					$display("outp[%d]: %h", raddr, outp);
					raddr = raddr + 1;
					if(raddr == `TOTAL_ADDR) begin
						raddr = 0;
						stateModExp = `TERMINAL;
					end
				end
				
				`TERMINAL:
				begin
					outp = 64'h0000000000000000;
				end
			endcase
		end
	end
	
endmodule
	