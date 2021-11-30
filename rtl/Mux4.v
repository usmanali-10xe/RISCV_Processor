module Mux4 #(parameter DWIDTH=32)
 (
	input		[DWIDTH-1:0]	in0,
	input		[DWIDTH-1:0]	in1,
	input		[DWIDTH-1:0]	in2,
	input		[DWIDTH-1:0]	in3,
	input		[1:0]		sel,
	output	reg	[DWIDTH-1:0]	mux_out
 );
always@*
	case(sel)
		2'b00: mux_out = in0;
		2'b01: mux_out = in1;
		2'b10: mux_out = in2;
		2'b11: mux_out = in3;	
	endcase
endmodule

