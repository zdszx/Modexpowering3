module BlackBlock ( G_i_k,P_i_k,G_km1_j,P_km1_j,G_i_j,P_i_j );
input G_i_k;
input P_i_k;
input G_km1_j;
input P_km1_j;
output G_i_j;
output P_i_j;
assign G_i_j = G_i_k | ( P_i_k & G_km1_j ) ;
assign P_i_j = P_i_k & P_km1_j ;
endmodule
