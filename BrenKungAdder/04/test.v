module test();
	reg[4:0] s_golden;
	reg[4:1] a,b;
	reg c_in;
	wire[4:1] s;

	BrentKungAdder adder(
							.A_1(a[1]), .B_1(b[1]),
							.A_2(a[2]), .B_2(b[2]),
							.A_3(a[3]), .B_3(b[3]),
							.A_4(a[4]), .B_4(b[4]),
							.C_0(c_in),
							.S_1(s[1]), .S_2(s[2]), 
							.S_3(s[3]), .S_4(s[4]), 
							.C_out(c_out));
	always @(a,b,c_in) begin
		s_golden = a + b + c_in;
	end

	initial begin
		c_in = 1'b0;
		a = 4'b0011;
		b = 4'b0010;
		#100
		$display("================================================================================================================");
		$display("In_1 = %d, In_2 = %d, c_in = %b, c_out = %b, My_Result = %d, Golden_Result = %d",a, b, c_in, c_out, s, s_golden);
		#100;
		c_in = 1'b0;
		a = 4'b1011;
		b = 4'b0110;
		#100
		$display("================================================================================================================");
		$display("In_1 = %d, In_2 = %d, c_in = %b, c_out = %b, My_Result = %d, Golden_Result = %d",a, b, c_in, c_out, s, s_golden);
		$display("================================================================================================================");
		#100;
	end
endmodule