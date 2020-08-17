// common header file
`ifndef __parameter_
`define __parameter_

`define DATA_WIDTH 64 
`define ADDR_WIDTH 5
`define TOTAL_ADDR (2 ** `ADDR_WIDTH)

`define TOTAL_BITS `DATA_WIDTH * `TOTAL_ADDR
`define ZERO 128'h00000000000000000000000000000000	// no use, please define it clearly in your modules, otherwise your simulation doesn't work

`define DATA_WIDTH64 64 
`define ADDR_WIDTH64 6
`define TOTAL_ADDR64 (2 ** `ADDR_WIDTH64)
`define ZERO64 64'h0000000000000000

`define DATA_WIDTH32 32
`define ADDR_WIDTH32 7
`define TOTAL_ADDR32 (2 ** `ADDR_WIDTH32)
`define ZERO32 32'h00000000


// Define states for ModExp
`define NONE 0000
`define LOADC 0001
`define WAIT_COMPUTE 0011
`define CALC_C_BAR 0010
`define GET_K_D 0110
`define BIGLOOP 0111
`define CALC_SQUARE 0101
`define CALC_M_BAR_1 0100
`define COMPLETE 1100
`define OUTPUT_RESULT 1101
`define TERMINAL 1111

// Define sub-states to communicate with MonPro module
`define NOTASK 0
`define INP1 1
`define INP2 2
`define WAIT 3
`define OUTPINS 4
// 		INP: dump values into MonPro		WAIT: wait for result	OUTPINS: dump values out from monPro	
				
// Define states for MonPro,	 stateMonPro
`define NONEMONPRO 0000
`define READINX 0001
`define READINY 0011
`define STEP1 0010
`define STEP2 0110
`define STEP3AND4 0111
`define STEP3AND4LASTV 0101
`define STEP5SUBCOND 0100
`define STEP5SUBTRACTION 1100
`define WRITEOUT 1101	


`endif