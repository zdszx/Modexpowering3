# ModExpowering3
a 2048 bit RSA verilog project basing on Montgomery , Karatsuba multiplier
what we actually used are:@ fate studio @ Brent Kung @Karatsuba

As to the adder module, booth-wallace seems to be a more acceptable choice, but it does not perform well in this project.
The max frequency is 222.32Mhz under 100Mhz clk, counter SCA measures are taken seldom consideration, which is the basic poweringladder montgomery.
The gray coding for finite state machine is very useful for decreasing the power. 
Residue Number System is a powerful choice, but unluckily a harder one.
