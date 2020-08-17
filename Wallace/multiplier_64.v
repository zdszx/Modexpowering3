`timescale 1ns / 1ps


module Wallace_multiplier_64(a, b, c );
    
input [31:0]a;
input [31:0]b;
output [63:0]c;    

//assign a = 32'b101010111010101010;
//assign b = 32'b1010101110101010; 
wire [7:0] am1, am2, am3, am4, am5, am6, am7, am8;
wire [63:0] man1, man2, man3, man4, man5, man6,  man7, man8;
wire [63:0] l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14, l15, l16;
wire [15:0] li1, li2, li3, li4, li5, li6, li7, li8, li9, li10, li11, li12, li13, li14, li15, li16;
wire [63:0] w1, w2, w3, w4, w5, w6;
wire w10;
assign am1[7:0] = a[7:0];
assign am2[7:0] = a[15:8];
assign am3[7:0] = a[23:16];
assign am4[7:0] = a[31:24];

assign am5[7:0] = b[7:0];
assign am6[7:0] = b[15:8];
assign am7[7:0] = b[23:16];
assign am8[7:0] = b[31:24];

wallace bc1(am1[7:0], am5[7:0], li1);
wallace bc2(am1, am6, li2);
wallace bc3(am1, am7, li3);
wallace bc4(am1, am8, li4);
wallace bc5(am2, am5, li5);
wallace bc6(am2, am6, li6);
wallace bc7(am2, am7, li7);
wallace bc8(am2, am8, li8);
wallace bc9(am3, am5, li9);
wallace bc10(am3, am6, li10);
wallace bc11(am3, am7, li11);
wallace bc12(am3, am8, li12);
wallace bc13(am4, am5, li13);
wallace bc14(am4, am6, li14);
wallace bc15(am4, am7, li15);
wallace bc16(am4, am8, li16);

assign l1 = {48'b0, li1[15:0]};
assign l2 = {40'b0, li2[15:0], 8'b0};
assign l5 = {40'b0, li5[15:0], 8'b0};
assign l6 = {40'b0, li6[15:0], 16'b0};
assign l9 = {40'b0, li9[15:0], 16'b0};
assign l3 = {40'b0, li3[15:0], 16'b0};
assign l4 = {32'b0, li4[15:0], 24'b0};
assign l7 = {32'b0, li7[15:0], 24'b0};
assign l10 = {24'b0, li10[15:0], 24'b0};
assign l13 = {24'b0, li13[15:0], 24'b0};
assign l11 = {16'b0, li11[15:0], 32'b0};
assign l14 = {16'b0, li14[15:0], 32'b0};
assign l8 =  {16'b0, li8[15:0], 32'b0};
assign l12 = {8'b0, li12[15:0], 40'b0};
assign l15 = {8'b0, li15[15:0], 40'b0};
assign l16 = {8'b0, li16[15:0], 48'b0};

adder_64 mc1(.a(l1), .b(l2), .sum(man1), .cout(w10));
adder_64 mc2(l3, l4, man2, w10);
adder_64 mc3(l5, l6, man3, w10);
adder_64 mc4(l7, l8, man4, w10);
adder_64 mc5(l9, l10, man5, w10);
adder_64 mc6(l11, l12, man6, w10);
adder_64 mc7(l13, l14, man7, w10);
adder_64 mc8(l15, l16, man8, w10);
adder_64 mc9(man1, man2, w1, w10);
adder_64 mc10(man3, man4, w2, w10);
adder_64 mc11(man5, man6, w3, w10);
adder_64 mc12(man7, man8, w4, w10);
adder_64 mc13(w1, w2, w5, w10);
adder_64 mc14(w3, w4, w6, w10);
adder_64 mc15(w5, w6, c, w10);

endmodule
