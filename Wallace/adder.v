`timescale 1ns / 1ps


module adder_64( a, b, sum, cout);
input [63:0]a; 
input [63:0]b;
output [63:0]sum;
output cout;

wire t1,t2, t3,t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19, t20, t21, t22, t23, t24, t25, t26, t27, t28, t29, t30, t31, t32, t33, t34, t35, t36, t37, t38, t39, t40, t41, t42, t43, t44, t45, t46, t47, t48, t49, t50, t51, t52, t53, t54, t55, t56, t57, t58, t59, t60, t61, t62, t63, t64; 
halfadder f1(a[0], b[0], sum[0], t1);
fulladder f2(a[1], b[1], t1, sum[1], t2);
fulladder f3(a[2], b[2], t2, sum[2], t3);
fulladder f4(a[3], b[3], t3, sum[3], t4);
fulladder f5(a[4], b[4], t4, sum[4], t5);
fulladder f6(a[5], b[5], t5, sum[5], t6);
fulladder f7(a[6], b[6], t6, sum[6], t7);
fulladder f8(a[7], b[7], t7, sum[7], t8);
fulladder f9(a[8], b[8], t8, sum[8], t9);
fulladder f10(a[9], b[9], t9, sum[9], t10);
fulladder f11(a[10], b[10], t10, sum[10], t11);
fulladder f12(a[11], b[11], t11, sum[11], t12);
fulladder f13(a[12], b[12], t12, sum[12], t13);
fulladder f14(a[13], b[13], t13, sum[13], t14);
fulladder f15(a[14], b[14], t14, sum[14], t15);
fulladder f16(a[15], b[15], t15, sum[15], t16);
fulladder f21(a[16], b[16], t16, sum[16], t17);
fulladder f22(a[17], b[17], t17, sum[17], t18);
fulladder f23(a[18], b[18], t18, sum[18], t19);
fulladder f24(a[19], b[19], t19, sum[19], t20);
fulladder f25(a[20], b[20], t20, sum[20], t21);
fulladder f26(a[21], b[21], t21, sum[21], t22);
fulladder f27(a[22], b[22], t22, sum[22], t23);
fulladder f28(a[23], b[23], t23, sum[23], t24);
fulladder f119(a[24], b[24], t24, sum[24], t25);
fulladder f29(a[25], b[25], t25, sum[25], t26);
fulladder f30(a[26], b[26], t26, sum[26], t27);
fulladder f31(a[27], b[27], t27, sum[27], t28);
fulladder f32(a[28], b[28], t28, sum[28], t29);
fulladder f33(a[29], b[29], t29, sum[29], t30);
fulladder f34(a[30], b[30], t30, sum[30], t31);
fulladder f35(a[31], b[31], t31, sum[31], t32);
fulladder f36(a[32], b[32], t32, sum[32], t33);
fulladder f37(a[33], b[33], t33, sum[33], t34);
fulladder f38(a[34], b[34], t34, sum[34], t35);
fulladder f55(a[35], b[35], t35, sum[35], t36);
fulladder f56(a[36], b[36], t36, sum[36], t37);
fulladder f455(a[37], b[37], t37, sum[37], t38);
fulladder f56434(a[38], b[38], t38, sum[38], t39);
fulladder f45641(a[39], b[39], t39, sum[39], t40);
fulladder f145(a[40], b[40], t40, sum[40], t41);
fulladder f472(a[41], b[41], t41, sum[41], t42);
fulladder f42(a[42], b[42], t42, sum[42], t43);
fulladder f45(a[43], b[43], t43, sum[43], t44);
fulladder f542(a[44], b[44], t44, sum[44], t45);
fulladder f53(a[45], b[45], t45, sum[45], t46);
fulladder f94(a[46], b[46], t46, sum[46], t47);
fulladder f244(a[47], b[47], t47, sum[47], t48);
fulladder f412(a[48], b[48], t48, sum[48], t49);
fulladder f152(a[49], b[49], t49, sum[49], t50);
fulladder f2114(a[50], b[50], t50, sum[50], t51);
fulladder f174(a[51], b[51], t51, sum[51], t52);
fulladder f172(a[52], b[52], t52, sum[52], t53);
fulladder f54(a[53], b[53], t53, sum[53], t54);
fulladder f564(a[54], b[54], t54, sum[54], t55);
fulladder f456(a[55], b[55], t55, sum[55], t56);
fulladder f345(a[56], b[56], t56, sum[56], t57);
fulladder f435(a[57], b[57], t57, sum[57], t58);
fulladder f451(a[58], b[58], t58, sum[58], t59);
fulladder fd4(a[59], b[59], t59, sum[59], t60);
fulladder fdsf(a[60], b[60], t60, sum[60], t61);
fulladder fd412(a[61], b[61], t61, sum[61], t62);
fulladder fds(a[62], b[62], t62, sum[62], t63);
fulladder fdf(a[63], b[63], t63, sum[63], cout);

endmodule








 