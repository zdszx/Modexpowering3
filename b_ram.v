
module b_ram(
				clock,
				data_in,
				waddr,
				raddr,
				rden,
				wren,
				data_out
				);
	input	        clock;
	input	        wren;
	input	        rden;
	input	 [4:0]  waddr,raddr;
	input	 [63:0] data_in;
	output [63:0] data_out;
	
	reg  [63:0] data_out;
	reg  [63:0] mem [31:0];
	
	always @(posedge clock)
    begin
        if (wren) begin
            mem[waddr] <= data_in;
       end else if (rden) begin
            data_out <= mem[raddr];
       end else begin
				data_out <= data_out;
		 end 
    end


endmodule 






