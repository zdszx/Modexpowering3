`timescale 1ns / 1ps


module fulladder( a,b,cin, sum, carry );
    input a;
    input b;
    input cin;
    output sum;
    output carry;
    
    wire t1,t2,t3;
   xor (sum, a, b, cin);
   and  (t1, a, b);
   and  (t2, b, cin);
   and (t3, a, cin);
   or (carry, t1, t2, t3);
    
endmodule

module halfadder(a,b,sum, carry);
    input a;
    input b;
    output carry;
    output sum;
    
    wire t2,t3,t4,t5;
    and g1(carry,a,b);
    not g3(t2,a);
    not g4(t3,b);
    and g5(t4,t2,b);
    and g6(t5,t3,a);
    or g7(sum,t4,t5);
    
endmodule


module wallace(input [7:0] a1, b1, output [15:0] result
    );
	 
	 wire [7:0] p0,p1,p2,p3,p4,p5,p6,p7;
//	 wire [9:0] a,b,cc,d;
//	 wire [10:0] c,ec,fc;
//	 wire [13:0] e;
//	 wire [14:0] f;
	 wire [7:0] r1, r2, r3, r4, r5, r6, r7, r8;
	 wire [64:0] cr;
	 wire [53:0] s;
	 
	 

	 assign r1[7:0] =  {8{b1[0]}};
	 assign r2[7:0] =  {8{b1[1]}};
	 assign r3[7:0] =  {8{b1[2]}};
	 assign r4[7:0] =  {8{b1[3]}};
	 assign r5[7:0] =  {8{b1[4]}};
	 assign r6[7:0] =  {8{b1[5]}};
	 assign r7[7:0] =  {8{b1[6]}};
	 assign r8[7:0] =  {8{b1[7]}};
	 
	 assign p0=a1&r1;
	 assign p1=a1&r2;
	 assign p2=a1&r3;
	 assign p3=a1&r4;
	 assign p4=a1&r5;
	 assign p5=a1&r6;
	 assign p6=a1&r7;
	 assign p7=a1&r8;
	
	assign result[0] = p0[0];
	halfadder a1241(p0[1], p1[0], s[1], cr[1]);
	fulladder a2(p0[2], p1[1], p2[0], s[2], cr[2]);
	fulladder a3(p0[3], p1[2], p2[1], s[3], cr[3]);
	fulladder a4(p0[4], p1[3], p2[2], s[4], cr[4]);	
	halfadder a5(p3[1], p4[0], s[10], cr[10]);
	fulladder a6(p0[5], p1[4], p2[3], s[5], cr[5]);
	fulladder a7(p3[2], p4[1], p5[0], s[11], cr[11]);
	fulladder a8(p0[6], p1[5], p2[4], s[6], cr[6]);
	fulladder a9(p3[3], p4[2], p5[1], s[12], cr[12]);
	fulladder a10(p0[7], p1[6], p2[5], s[7], cr[7]);
	fulladder a11(p3[4], p4[3], p5[2], s[13], cr[13]);
	halfadder a12(p1[7], p2[6], s[8], cr[8]);
	fulladder a13(p3[5], p4[4], p5[3], s[14], cr[14]);
	fulladder a14(p2[7], p3[6], p4[5], s[9], cr[9]);
	fulladder a15(p3[7], p4[6], p5[5], s[15], cr[15]);
	halfadder a16(p4[7], p5[6], s[16], cr[16]);	

	assign result[1] = s[1];
	halfadder a17(s[2], cr[1], s[17], cr[17]);
	fulladder a18(s[3], cr[2], p3[0], s[18], cr[18]);
	fulladder a19(s[4], cr[3], s[10], s[19], cr[19]);		
	fulladder a20(s[5], cr[4], s[11], s[20], cr[20]);
	fulladder a21(s[6], cr[5], s[12], s[21], cr[21]);  	
	fulladder a22(s[7], cr[6], s[13], s[22], cr[22]);
	fulladder a23(s[8], cr[7], s[14], s[23], cr[23]);
	fulladder a24(s[9], cr[8], cr[14], s[24], cr[24]);
	fulladder a25(cr[9], p6[4], p7[3], s[29], cr[29]);		
	fulladder a26(cr[15], p6[5], p7[4], s[30], cr[30]);
	fulladder a27(p5[7], p6[6], p7[5], s[31], cr[31]);
	halfadder a28(p6[7], p7[6], s[32], cr[32]);
	halfadder a29(p6[0], cr[11], s[25], cr[25]);
	fulladder a30(cr[12], p6[1], p7[0], s[26], cr[26]);
	fulladder a31(cr[13], p6[2], p7[1], s[27], cr[27]);
	fulladder a32(p5[4], p6[3], p7[2], s[28], cr[28]);

	assign result[2] = s[17];
	halfadder a33(s[18], cr[17], s[33], cr[33]);
	halfadder a34(s[19], cr[18], s[34], cr[34]);
	fulladder a35(s[20], cr[19], cr[10], s[35], cr[35]);
	fulladder a36(s[21], cr[20], s[25], s[36], cr[36]);
	fulladder a37(s[22], cr[21], s[26], s[37], cr[37]);
	fulladder a38(s[23], cr[22], s[27], s[38], cr[38]);
	fulladder a39(s[24], cr[23], s[28], s[39], cr[39]);
	fulladder a40(s[15], cr[24], s[29], s[40], cr[40]);
	halfadder a41(s[16], s[30], s[41], cr[41]);
	halfadder a42(cr[16], s[31], s[42], cr[42]);
	
	assign result[3] = s[33];
	halfadder a43(s[34], cr[33], s[43], cr[43]);
	halfadder a44(s[35], cr[34], s[44], cr[44]);
	halfadder a45(s[36], cr[35], s[45], cr[45]);
	fulladder a46(s[37], cr[36], cr[25], s[46], cr[46]);
	fulladder a47(s[38], cr[37], cr[26], s[47], cr[47]);	
	fulladder a48(s[39], cr[38], cr[27], s[48], cr[48]);
	fulladder a49(s[40], cr[39], cr[28], s[49], cr[49]);	
	fulladder a50(s[41], cr[40], cr[29], s[50], cr[50]);	
	fulladder a51(s[42], cr[30], cr[41], s[51], cr[51]);	
	fulladder a52(cr[42], s[32], cr[31], s[52], cr[52]);	
	halfadder a53(p7[7], cr[32], s[53], cr[53]);
	
	assign result[4] = s[43];
	halfadder a54(s[44], cr[43], result[5], cr[54]);
	fulladder a55(s[45], cr[44], cr[54], result[6], cr[55]);	
	fulladder a56(s[46], cr[45], cr[55], result[7], cr[56]);
	fulladder a57(s[47], cr[46], cr[56], result[8], cr[57]);
	fulladder a58(s[48], cr[47], cr[57], result[9], cr[58]);
	fulladder a59(s[49], cr[48], cr[58], result[10], cr[59]);
	fulladder a60(s[50], cr[49], cr[59], result[11], cr[60]);
	fulladder a61(s[51], cr[50], cr[60], result[12], cr[61]);
	fulladder a62(s[52], cr[51], cr[61], result[13], cr[62]);
	fulladder a63(s[53], cr[52], cr[62], result[14], cr[63]);
	assign result[15] = cr[53];
      
	 
endmodule
