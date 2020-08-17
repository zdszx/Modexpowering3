module BitwisePGLogic ( A_1,B_1,A_2,B_2,A_3,B_3,A_4,B_4,C_0,P_0,G_0,P_1,G_1,P_2,G_2,P_3,G_3,P_4,G_4 );
input A_1;
input B_1;
input A_2;
input B_2;
input A_3;
input B_3;
input A_4;
input B_4;
input C_0;
output P_0;
output G_0;
output P_1;
output G_1;
output P_2;
output G_2;
output P_3;
output G_3;
output P_4;
output G_4;
// Bit 0
assign P_0 = 0 ;
assign G_0 = C_0 ;
// Bit 1
PG PG_Bit_1(.A_i(A_1),.B_i(B_1),.P_i(P_1),.G_i(G_1));
// Bit 2
PG PG_Bit_2(.A_i(A_2),.B_i(B_2),.P_i(P_2),.G_i(G_2));
// Bit 3
PG PG_Bit_3(.A_i(A_3),.B_i(B_3),.P_i(P_3),.G_i(G_3));
// Bit 4
PG PG_Bit_4(.A_i(A_4),.B_i(B_4),.P_i(P_4),.G_i(G_4));
endmodule
