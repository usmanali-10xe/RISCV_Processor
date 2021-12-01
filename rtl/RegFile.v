module RegFile #(parameter RAWIDTH=5, DWIDTH=32)
 (
	input				clk,
	input				RegWEn,
	input		[RAWIDTH-1:0]	AddrA,
	input		[RAWIDTH-1:0]	AddrB,
	input		[RAWIDTH-1:0]	AddrD,
	input		[DWIDTH-1:0]	DataD,
	output   	[DWIDTH-1:0]	DataA,
	output   	[DWIDTH-1:0]	DataB
 );
	reg [DWIDTH-1:0] register [2**RAWIDTH-1:0];
	assign	DataA = register[AddrA];
	assign	DataB = register[AddrB];

always @ (posedge clk)
begin
	register[AddrD] <= RegWEn ? DataD : register[AddrD] ;
	register[0] 	<= {DWIDTH{1'b0}}; 
end
			
endmodule
