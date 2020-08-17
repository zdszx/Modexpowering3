//Date		: 2020/05/26
//Author	: zhishangtanxin 
//Function	: 
//read more, please refer to wechat public account "zhishangtanxin"
module booth_top(
	input [15:0] A,
	input [15:0] B,
	output [31:0] P
);
wire [7:0] neg;
wire [7:0] zero;
wire [7:0] one;
wire [7:0] two;

genvar i;
generate 
	for(i=0; i<8; i++)begin
		if(i==0)
			booth_enc u_booth_enc(
				.code ({B[1:0],1'b0}),
				.neg  (neg[i]    ),
				.zero (zero[i]   ),
				.one  (one[i]	 ),
				.two  (two[i]	 )
			);
		else
			booth_enc u_booth_enc(
				.code (B[i*2+1:i*2-1]),
				.neg  (neg[i]    ),
				.zero (zero[i]   ),
				.one  (one[i]	 ),
				.two  (two[i]	 )
			);
	end
endgenerate

wire [7:0][31:0] prod;
generate 
	for(i=0; i<8; i++)begin
		gen_prod u_gen_prod (
			.A    ( A       ),
			.neg  ( neg[i]  ),
			.zero ( zero[i] ),
			.one  ( one[i]  ),
			.two  ( two[i]  ),
			.prod ( prod[i] )
		);
	end
endgenerate

wallace_tree u_watree(
    .prod(prod),
    .P(P)
);
endmodule
