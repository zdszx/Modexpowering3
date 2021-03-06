module test();
	reg[8:0] s_golden;
	reg[8:1] a,b;
	reg c_in;
	wire[8:1] s;

	BrentKungAdder adder(
							.A_1(a[1]), .B_1(b[1]),
							.A_2(a[2]), .B_2(b[2]),
							.A_3(a[3]), .B_3(b[3]),
							.A_4(a[4]), .B_4(b[4]),
							.A_5(a[5]), .B_5(b[5]),
							.A_6(a[6]), .B_6(b[6]),
							.A_7(a[7]), .B_7(b[7]),
							.A_8(a[8]), .B_8(b[8]),
							.C_0(c_in),
							.S_1(s[1]), .S_2(s[2]), 
							.S_3(s[3]), .S_4(s[4]), 
							.S_5(s[5]), .S_6(s[6]), 
							.S_7(s[7]), .S_8(s[8]), 
							.C_out(c_out));
	always @(a,b,c_in) begin
		s_golden = a + b + c_in;
	end

	initial begin
		c_in = 1'b0;
		a = 8'b0011;
		b = 8'b0001;
		#100
		$display("================================================================================================================");
		$display("In_1 = %d, In_2 = %d, c_in = %b, c_out = %b, My_Result = %d, Golden_Result = %d",a, b, c_in, c_out, s, s_golden);
		#100;
		c_in = 1'b0;
		a = 8'b10000101;
		b = 8'b10001100;
		#100
		$display("================================================================================================================");
		$display("In_1 = %d, In_2 = %d, c_in = %b, c_out = %b, My_Result = %d, Golden_Result = %d",a, b, c_in, c_out, s, s_golden);
		$display("================================================================================================================");
		#100;
	end
endmodule