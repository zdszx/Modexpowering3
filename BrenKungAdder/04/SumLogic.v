module SumLogic ( P_0,G_0_0,P_1,G_1_0,P_2,G_2_0,P_3,G_3_0,P_4,G_4_0,S_1,S_2,S_3,S_4,C_out );
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
output S_1;
output S_2;
output S_3;
output S_4;
output C_out;
// Bit 1
assign S_1 = G_0_0 ^ P_1 ;
// Bit 2
assign S_2 = G_1_0 ^ P_2 ;
// Bit 3
assign S_3 = G_2_0 ^ P_3 ;
// Bit 4
assign S_4 = G_3_0 ^ P_4 ;
// Carry Out
assign C_out = G_4_0 ;
endmodule
