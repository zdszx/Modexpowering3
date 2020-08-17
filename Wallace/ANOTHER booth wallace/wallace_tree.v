//Date		: 2020/05/26
//Author	: zhishangtanxin 
//Function	: 
//read more, please refer to wechat public account "zhishangtanxin"
module wallace_tree (
	input [7:0][31:0] prod,
    output [31:0] P
);

wire [31:0] s_lev01;
wire [31:0] c_lev01;
wire [31:0] s_lev02;
wire [31:0] c_lev02;
wire [31:0] s_lev11;
wire [31:0] c_lev11;
wire [31:0] s_lev12;
wire [31:0] c_lev12;
wire [31:0] s_lev21;
wire [31:0] c_lev21;
wire [31:0] s_lev31;
wire [31:0] c_lev31;

//level 0
csa #(32) csa_lev01(
	.op1( prod[0]      ),
	.op2( prod[1] << 2 ),
	.op3( prod[2] << 4 ),
	.S	( s_lev01      ),
	.C	( c_lev01      )
);

csa #(32) csa_lev02(
	.op1( prod[3] << 6 ),
	.op2( prod[4] << 8 ),
	.op3( prod[5] << 10 ),
	.S	( s_lev02      ),
	.C	( c_lev02      )
);

//level 1
csa #(32) csa_lev11(
	.op1( s_lev01      ),
	.op2( c_lev01 << 1 ),
	.op3( s_lev02      ),
	.S	( s_lev11      ),
	.C	( c_lev11      )
);

csa #(32) csa_lev12(
	.op1( c_lev02 << 1 ),
	.op2( prod[6] << 12),
	.op3( prod[7] << 14),
	.S	( s_lev12      ),
	.C	( c_lev12      )
);

//level 2
csa #(32) csa_lev21(
	.op1( s_lev11      ),
	.op2( c_lev11 << 1 ),
	.op3( s_lev12      ),
	.S	( s_lev21      ),
	.C	( c_lev21      )
);

//level 3
csa #(32) csa_lev31(
	.op1( s_lev21 ),
	.op2( c_lev21 << 1 ),
	.op3( c_lev12 << 1 ),
	.S	( s_lev31),
	.C	( c_lev31)
);

//adder
rca #(32) u_rca (
    .op1 ( s_lev31  ), 
    .op2 ( c_lev31 << 1  ),
    .cin ( 1'b0   ),
    .sum ( P      ),
    .cout(        )
);

endmodule
