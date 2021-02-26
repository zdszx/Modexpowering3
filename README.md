# ModExpowering3
a 2048 bit RSA verilog project basing on Montgomery , Karatsuba multiplier

what we actually used are:@ fate studio @ Brent Kung Adder @Karatsuba multiplier

## **1. Summary**:
<img src="https://github.com/zdszx/Modexpowering3/blob/master/1.png" width="600" height="200" /><br/>

## **2. Architecture of the project:**
![image](https://github.com/zdszx/Modexpowering3/blob/master/2.png)

## **3. Mainmodule ModExpPoweringladder:**
![image](https://github.com/zdszx/Modexpowering3/blob/master/3.png)

## **4. Submodule MonPro:**
![image](https://github.com/zdszx/Modexpowering3/blob/master/4.png)

## **5. Verify via python**

## **6. UVM testbench :**
![image](https://github.com/zdszx/Modexpowering3/blob/master/5.png)

As to the adder module, booth-wallace seems to be a more acceptable choice, but it does not perform well in this project.
The max frequency is 222.32Mhz under 100Mhz clk, counter SCA measures are taken seldom consideration, which is the basic poweringladder montgomery.

The gray coding for finite state machine is very useful for decreasing the power. 
Residue Number System is a powerful choice, but unluckily a harder one.
