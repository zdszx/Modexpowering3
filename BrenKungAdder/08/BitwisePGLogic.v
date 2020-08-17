module BitwisePGLogic ( A_1,B_1,A_2,B_2,A_3,B_3,A_4,B_4,A_5,B_5,A_6,B_6,A_7,B_7,A_8,B_8,C_0,P_0,G_0,P_1,G_1,P_2,G_2,P_3,G_3,P_4,G_4,P_5,G_5,P_6,G_6,P_7,G_7,P_8,G_8 );
input A_1;
input B_1;
input A_2;
input B_2;
input A_3;
input B_3;
input A_4;
input B_4;
input A_5;
input B_5;
input A_6;
input B_6;
input A_7;
input B_7;
input A_8;
input B_8;
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
output P_5;
output G_5;
output P_6;
output G_6;
output P_7;
output G_7;
output P_8;
output G_8;
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
// Bit 5
PG PG_Bit_5(.A_i(A_5),.B_i(B_5),.P_i(P_5),.G_i(G_5));
// Bit 6
PG PG_Bit_6(.A_i(A_6),.B_i(B_6),.P_i(P_6),.G_i(G_6));
// Bit 7
PG PG_Bit_7(.A_i(A_7),.B_i(B_7),.P_i(P_7),.G_i(G_7));
// Bit 8
PG PG_Bit_8(.A_i(A_8),.B_i(B_8),.P_i(P_8),.G_i(G_8));
endmodule
