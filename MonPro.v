// MonPro module
// follow this algorithm: http://cs.ucsb.edu/~koc/cs290g/docs/w01/mon1.pdf
`include "_parameter.v"

module MonPro
(
	input clk,
	input reset,
	input [0: 0] start,
	input [`DATA_WIDTH - 1 : 0] n0_data,
	input [`DATA_WIDTH - 1 : 0] n_data,
	input [`DATA_WIDTH - 1 : 0] inp,	// data input pins
	output reg [4 : 0] state,
	output reg [`DATA_WIDTH - 1 : 0] outp	// data output pins
);

	reg [`DATA_WIDTH - 1 : 0] x [`TOTAL_ADDR : 0];	
	reg [`DATA_WIDTH - 1 : 0] y [`TOTAL_ADDR : 0];	// we need one more word for y, because when vector(v) = (m * vector(n) + vector(v)) >> WIDTH, it may have one more word on top that we need to keep to the next loop.
	
	//reg [`DATA_WIDTH - 1 : 0] n0 [0 : 0];	// a memory must have unpacked array!
	reg [`DATA_WIDTH - 1 : 0] n [`TOTAL_ADDR - 1 : 0];
	
	reg [`DATA_WIDTH - 1 : 0] c;
	reg [`DATA_WIDTH - 1 : 0] v [`TOTAL_ADDR + 1 : 0];	// v is the temp and final result
	reg [`DATA_WIDTH - 1 : 0] m;
	
	integer i;	// big loop i
	integer j;	// small loop j
	integer k;	// clock upper edge and down edge
	
/*
	initial begin	// set to 0 
		$readmemh("nprime0.txt", nprime0);
		$readmemh("n.txt", n);
		
		for(j = 0; j < `TOTAL_ADDR + 2; j = j + 1) begin
			v[j] = 64'h0000000000000000;
		end
		for(j = 0; j < `TOTAL_ADDR + 1; j = j + 1) begin
			x[j] = 64'h0000000000000000;
			y[j] = 64'h0000000000000000;
		end
		outp = 64'h0000000000000000;
						
		c = 64'h0000000000000000;	// initial C = 0
		i = 0;
		j = 0;
		k = 0;
		state = `NONEMONPRO;
	end
*/
	reg [`DATA_WIDTH - 1 : 0] x0;
	reg [`DATA_WIDTH - 1 : 0] y0;
	reg [`DATA_WIDTH - 1 : 0] z0;
	reg [`DATA_WIDTH - 1 : 0] last_c0;
	reg [`DATA_WIDTH - 1 : 0] now_c0;
	wire [`DATA_WIDTH - 1 : 0] s0;
	wire [`DATA_WIDTH - 1 : 0] c0;
	mul_add mul_add0(
					.clk(clk),
					.x(x0), 
					.y(y0), 
					.z(z0), 
					.last_c(last_c0), 
					.s(s0), 
					.c(c0));
				
	always @ (posedge clk or posedge reset) begin
		if (reset) begin	// reset state
			for(j = 0; j < `TOTAL_ADDR + 2; j = j + 1) begin
				v[j] = 64'h0000000000000000;
			end
			for(j = 0; j < `TOTAL_ADDR + 1; j = j + 1) begin
				x[j] = 64'h0000000000000000;
				y[j] = 64'h0000000000000000;
			end
			outp = 64'h0000000000000000;
			i <= 0;
			j <= 0;
			state <= `NONEMONPRO;
		end
		else begin
			case (state)
				`NONEMONPRO:	// NONEMONPRO state
				begin
					if(start == 1) begin
						state = `READINX;
					end
				end
				
				`READINX:	// readin state
				begin
					if(j < `TOTAL_ADDR) begin
						x[j] = inp;
						n[j] = n_data;
						j = j + 1;
					end
					else begin
						j = 0;
						state = `READINY;
					end
				end

				`READINY:	// readin state		There are two full clocks' delay here. ?? No idea about the reason.
				begin
					if(j < `TOTAL_ADDR) begin
						y[j] = inp;
						
						j = j + 1;
					end
					else begin
						j = 0;
						state = `STEP1;
					end
				end	
	
				`STEP1:	// MonPro computation step 1 in ICD document
				begin	// vector(v) = x[0] * y + prev[vector(v)] + z
					if(k == 0) begin	// first clock: initial input 
						// initial a new multiplier computation
						x0 <= x[i];
						y0 <= y[j];
						z0 <= v[j];
						last_c0 <= c;
						k = 1;
					end 
					else if(k == 1) begin	// second clock: store output
						// store the output of multiplier
						v[j] <= s0;
						c <= c0;
						j = j + 1;
						if(j == `TOTAL_ADDR + 1) begin	// loop end
							j = 0;
							state = `STEP2;
						end
						k = 0;
					end 
				end
				
				`STEP2:	// step 2 of ICD document, MonPro section
				begin // m = (v[0] * n0_prime) mod 2^w
					if(k == 0) begin	// first clock: initial input 
						x0 <= v[0];
						y0 <= n0_data;
						z0 <= 64'h0000000000000000;
						last_c0 <= 64'h0000000000000000;
						k = 1;
					end
					else if(k == 1) begin
						m <= s0;	
						state = `STEP3AND4;
						k = 0;
					end
				end
				
				`STEP3AND4:	// step 3 and 4 of ICD document
				begin // vector(v) = (m * vector(n) + vector(v)) >> WIDTH
				// (C, S) = v[0] + m * n[0]
					if(k == 0) begin
						x0 <= m;
						
						if(j == `TOTAL_ADDR) begin		// n[`TOTAL_ADDR] = 0
							y0 <= 64'h0000000000000000;
						end
						else begin
							y0 <= n[j];
						end
						
						z0 <= v[j];
						
						if(j == 0) begin	// initial last_c0 is 0
							last_c0 <= 64'h0000000000000000;
						end
						else begin
							last_c0 <= c;
						end
						
						k = 1;
					end
					else if(k == 1) begin
						v[j - 1] <= s0;
						c <= c0;	
						j = j + 1;	
							
						if(j == `TOTAL_ADDR + 1) begin
							j = 0;
							state = `STEP3AND4LASTV;
						end
						k = 0;
					end
				end
				
				`STEP3AND4LASTV:	// generate last Z word, and give to V		deal with the last word
				begin // v[s] = v[s + 1] + C
					if(k == 0) begin
						x0 <= 64'h0000000000000000;
						y0 <= 64'h0000000000000000;
						z0 <= v[`TOTAL_ADDR + 1];
						last_c0 <= c;
						k = 1;
					end
					else if(k == 1) begin
						v[`TOTAL_ADDR] <= s0;
						i = i + 1;		// one turn finished, bigger loop +1
						c = 64'h0000000000000000;
						state = `STEP1;
						if(i >= `TOTAL_ADDR) begin	// end	here is still `TOTAL_ADDR because we only have `TOTAL_ADDR - 1 words of x
							state = `STEP5SUBCOND;
							i = `TOTAL_ADDR - 1;
						end
						k = 0;
					end
				end
				
				`STEP5SUBCOND:	// if v >= n, v = v - n		first part: subtraction condition 
				begin 
					if(v[i] > n[i]) begin	// do v = v - n for all...
						i = 0;
						last_c0 = 0;	// carry bit
						state = `STEP5SUBTRACTION;
					end
					else if(v[i] == n[i]) begin
						i = i - 1;
					end
					else begin	// skip subtraction
						i = 0;
						state = `WRITEOUT;
					end
					
				end

				`STEP5SUBTRACTION:	// if v >= n, v = v - n		second part: subtraction 
				begin 	// do v = v - n for all words
					if(v[i] >= n[i] + last_c0) begin	 // last_c0 is the carry bit caused by previous subtraction. now_c0 is carry bit generated by current subtraction.
						now_c0 = 0;
					end
					else begin	
						now_c0 = 1;
					end
					v[i] = v[i] - n[i] - last_c0;
					last_c0 = now_c0;
					i = i + 1;
					if(i == `TOTAL_ADDR) begin
						state = `WRITEOUT;
						i = 0;
					end
				end
				
				`WRITEOUT:
				begin
					if(j < `TOTAL_ADDR) begin
						outp = v[j];
						j = j + 1;
					end
					else begin
						for(j = 0; j < `TOTAL_ADDR + 2; j = j + 1) begin
							v[j] = 64'h0000000000000000;
						end
						for(j = 0; j < `TOTAL_ADDR; j = j + 1) begin
							x[j] = 64'h0000000000000000;
							y[j] = 64'h0000000000000000;
						end
						outp = 64'h0000000000000000;
						i = 0;
						j = 0;
						state = `NONEMONPRO;
					end
				end
				
			endcase					
		end
	end
	
endmodule
	