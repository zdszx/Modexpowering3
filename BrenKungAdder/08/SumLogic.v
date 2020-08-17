module SumLogic ( P_0,G_0_0,P_1,G_1_0,P_2,G_2_0,P_3,G_3_0,P_4,G_4_0,P_5,G_5_0,P_6,G_6_0,P_7,G_7_0,P_8,G_8_0,S_1,S_2,S_3,S_4,S_5,S_6,S_7,S_8,C_out );
input P_0;
input G_0_0;
input P_1;
input G_1_0;
input P_2;
input G_2_0;
input P_3;
input G_3_0;
input P_4;
input G_4_0;
input P_5;
input G_5_0;
input P_6;
input G_6_0;
input P_7;
input G_7_0;
input P_8;
input G_8_0;
output S_1;
output S_2;
output S_3;
output S_4;
output S_5;
output S_6;
output S_7;
output S_8;
output C_out;
// Bit 1
assign S_1 = G_0_0 ^ P_1 ;
// Bit 2
assign S_2 = G_1_0 ^ P_2 ;
// Bit 3
assign S_3 = G_2_0 ^ P_3 ;
// Bit 4
assign S_4 = G_3_0 ^ P_4 ;
// Bit 5
assign S_5 = G_4_0 ^ P_5 ;
// Bit 6
assign S_6 = G_5_0 ^ P_6 ;
// Bit 7
assign S_7 = G_6_0 ^ P_7 ;
// Bit 8
assign S_8 = G_7_0 ^ P_8 ;
// Carry Out
assign C_out = G_8_0 ;
endmodule
