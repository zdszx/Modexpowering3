// (multiplication, addition) component for MonPro
`include "_parameter.v"

module mul_add
(
	input clk,
	input [`DATA_WIDTH : 1] x,
	input [`DATA_WIDTH : 1] y,
	input [`DATA_WIDTH : 1] z,
	input [`DATA_WIDTH : 1] last_c,
	output [`DATA_WIDTH : 1] s,	// lower output
	output [`DATA_WIDTH : 1] c	   // higher output
);

	// Declare input and output registers
	// wire [`DATA_WIDTH-1 : 0] mult_outX; wire cout;
   // KSA64 KSA64X(.sum(mult_outX), .cout(cout),.a(z),.b(last_c));
	
	reg  [2 * `DATA_WIDTH - 1 : 0] mult_out; //change wire
	
	   wire [63 : 0] z0;
	//Wallace_multiplier_64 Wallace_multiplier0 (.a(a1), .b(b1), .c(z0));
		karatsuba_top karatsuba_top0(.x(a1),.y(b1),.z(z0));
		wire [63 : 0] z1;
	   karatsuba_top karatsuba_top1(.x(a1),.y(b2),.z(z1));
		wire [63 : 0] z2;
	//Wallace_multiplier_64 Wallace_multiplier2 (.a(a2), .b(b1), .c(z2));
		karatsuba_top karatsuba_top2(.x(a2),.y(b1),.z(z2));
		wire [63 : 0] z3;
	//Wallace_multiplier_64 Wallace_multiplier3 (.a(a2), .b(b2), .c(z3));
		karatsuba_top karatsuba_top3(.x(a2),.y(b2),.z(z3));
	
   wire[64:1] s0;
   reg c_in=1'b0;
   wire c_out;
   BrentKungAdder adder(
							.A_1(z[1]), .B_1(last_c[1]),.A_2(z[2]), .B_2(last_c[2]),.A_3(z[3]), .B_3(last_c[3]),.A_4(z[4]), .B_4(last_c[4]),
							.A_5(z[5]), .B_5(last_c[5]),.A_6(z[6]), .B_6(last_c[6]),.A_7(z[7]), .B_7(last_c[7]),.A_8(z[8]), .B_8(last_c[8]),
							.A_9(z[9]), .B_9(last_c[9]),.A_10(z[10]), .B_10(last_c[10]),.A_11(z[11]), .B_11(last_c[11]),.A_12(z[12]), .B_12(last_c[12]),
							.A_13(z[13]), .B_13(last_c[13]),.A_14(z[14]), .B_14(last_c[14]),.A_15(z[15]), .B_15(last_c[15]),.A_16(z[16]), .B_16(last_c[16]),
							.A_17(z[17]), .B_17(last_c[17]),.A_18(z[18]), .B_18(last_c[18]),.A_19(z[19]), .B_19(last_c[19]),.A_20(z[20]), .B_20(last_c[20]),
							.A_21(z[21]), .B_21(last_c[21]),.A_22(z[22]), .B_22(last_c[22]),.A_23(z[23]), .B_23(last_c[23]),.A_24(z[24]), .B_24(last_c[24]),
							.A_25(z[25]), .B_25(last_c[25]),.A_26(z[26]), .B_26(last_c[26]),.A_27(z[27]), .B_27(last_c[27]),.A_28(z[28]), .B_28(last_c[28]),
							.A_29(z[29]), .B_29(last_c[29]),.A_30(z[30]), .B_30(last_c[30]),.A_31(z[31]), .B_31(last_c[31]),.A_32(z[32]), .B_32(last_c[32]),
							.A_33(z[33]), .B_33(last_c[33]),.A_34(z[34]), .B_34(last_c[34]),.A_35(z[35]), .B_35(last_c[35]),.A_36(z[36]), .B_36(last_c[36]),
							.A_37(z[37]), .B_37(last_c[37]),.A_38(z[38]), .B_38(last_c[38]),.A_39(z[39]), .B_39(last_c[39]),.A_40(z[40]), .B_40(last_c[40]),
							.A_41(z[41]), .B_41(last_c[41]),.A_42(z[42]), .B_42(last_c[42]),.A_43(z[43]), .B_43(last_c[43]),.A_44(z[44]), .B_44(last_c[44]),
							.A_45(z[45]), .B_45(last_c[45]),.A_46(z[46]), .B_46(last_c[46]),.A_47(z[47]), .B_47(last_c[47]),.A_48(z[48]), .B_48(last_c[48]),
							.A_49(z[49]), .B_49(last_c[49]),.A_50(z[50]), .B_50(last_c[50]),.A_51(z[51]), .B_51(last_c[51]),.A_52(z[52]), .B_52(last_c[52]),
							.A_53(z[53]), .B_53(last_c[53]),.A_54(z[54]), .B_54(last_c[54]),.A_55(z[55]), .B_55(last_c[55]),.A_56(z[56]), .B_56(last_c[56]),
							.A_57(z[57]), .B_57(last_c[57]),.A_58(z[58]), .B_58(last_c[58]),.A_59(z[59]), .B_59(last_c[59]),.A_60(z[60]), .B_60(last_c[60]),
							.A_61(z[61]), .B_61(last_c[61]),.A_62(z[62]), .B_62(last_c[62]),.A_63(z[63]), .B_63(last_c[63]),.A_64(z[64]), .B_64(last_c[64]),
							.C_0(c_in),
							.S_1(s0[1]), .S_2(s0[2]), .S_3(s0[3]), .S_4(s0[4]), .S_5(s0[5]), .S_6(s0[6]), .S_7(s0[7]), .S_8(s0[8]), 
							.S_9(s0[9]), .S_10(s0[10]), .S_11(s0[11]), .S_12(s0[12]), .S_13(s0[13]), .S_14(s0[14]), .S_15(s0[15]), .S_16(s0[16]), 
							.S_17(s0[17]), .S_18(s0[18]), .S_19(s0[19]), .S_20(s0[20]), .S_21(s0[21]), .S_22(s0[22]), .S_23(s0[23]), .S_24(s0[24]), 
							.S_25(s0[25]), .S_26(s0[26]), .S_27(s0[27]), .S_28(s0[28]), .S_29(s0[29]), .S_30(s0[30]), .S_31(s0[31]), .S_32(s0[32]), 
							.S_33(s0[33]), .S_34(s0[34]), .S_35(s0[35]), .S_36(s0[36]), .S_37(s0[37]), .S_38(s0[38]), .S_39(s0[39]), .S_40(s0[40]), 
							.S_41(s0[41]), .S_42(s0[42]), .S_43(s0[43]), .S_44(s0[44]), .S_45(s0[45]), .S_46(s0[46]), .S_47(s0[47]), .S_48(s0[48]), 
							.S_49(s0[49]), .S_50(s0[50]), .S_51(s0[51]), .S_52(s0[52]), .S_53(s0[53]), .S_54(s0[54]), .S_55(s0[55]), .S_56(s0[56]), 
							.S_57(s0[57]), .S_58(s0[58]), .S_59(s0[59]), .S_60(s0[60]), .S_61(s0[61]), .S_62(s0[62]), .S_63(s0[63]), .S_64(s0[64]), 
							.C_out(c_out));
	
	
	reg[64:1] mult_out1;
	reg[96:1] mult_out2;
   reg[96:1] mult_out3;
	reg[128:1] mult_out4,mult_out5,mult_out6;
   wire[32:1] a1,a2,b1,b2;
   assign a2=x[64:33];
	assign a1=x[32:1];
	assign b2=y[64:33];
	assign b1=y[32:1];
	always @(posedge clk)
	begin
	   mult_out1<=z0;                //clog
		mult_out2<=z1<<32;
		mult_out3<=z2<<32;
		mult_out4<=z3<<64;
	end
   always @(posedge clk)
	begin
	   mult_out5<=mult_out1+{c_out, s0};  //clog
		mult_out6<=mult_out3+mult_out2+mult_out4;
	end
	
	always@(posedge clk)
	begin
	   mult_out<=mult_out5+mult_out6;
	end


	assign s = mult_out[`DATA_WIDTH - 1 : 0];
	assign c = mult_out[2 * `DATA_WIDTH - 1 : `DATA_WIDTH];

endmodule
