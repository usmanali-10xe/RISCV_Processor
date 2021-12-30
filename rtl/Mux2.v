module Mux2 #(parameter DWIDTH=32)
 (
	input		[DWIDTH-1:0]	in0,
	input		[DWIDTH-1:0]	in1,
	input				sel,
	output		[DWIDTH-1:0]	mux_out
 );
	
	assign	mux_out = sel? in1 : in0;
			
endmodule

