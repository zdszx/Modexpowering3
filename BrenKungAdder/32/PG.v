module PG ( A_i,B_i,G_i,P_i );
input A_i;
input B_i;
output G_i;
output P_i;
assign G_i = A_i & B_i ;
assign P_i = A_i ^ B_i ;
endmodule
