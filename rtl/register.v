module register#(parameter WIDTH=32)
(
  input wire  clk,
  input wire  rst,
  input wire  load,
  input wire  [WIDTH-1:0] data_in,
  output reg  [WIDTH-1:0] data_out
);
always@(posedge clk)
  begin
	data_out <= rst?  {WIDTH{1'b0}}
		  : load? data_in
		  : 	  data_out;
  end
endmodule 
