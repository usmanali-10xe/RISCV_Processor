module IMEM #(parameter AWIDTH=32, IWIDTH=32)
 (
	input				clk,
	input				ILoad,
	input		[AWIDTH-1:0]	IAddr,
	input		[IWIDTH-1:0]	instW,
	output   	[IWIDTH-1:0]	inst
 );
 	localparam accessable_bits = 8;
	reg [7:0] Instruction [0:1023];
	// will do it with generate block for flexibility
	// big endian because of memory readformat 
	assign	inst = {Instruction[IAddr],Instruction[IAddr+1],Instruction[IAddr+2],Instruction[IAddr+3]};
	//assign	inst = Instruction[IAddr];
endmodule
