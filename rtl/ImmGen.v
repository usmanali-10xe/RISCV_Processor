module ImmGen #(parameter DWIDTH=32, IWIDTH=32)
(
	input		[IWIDTH-8:0]	inst,
	input 		[2:0]		ImmSel,
	output reg	[DWIDTH-1:0]	Imm
);

always@*
	case(ImmSel[2:0])
	// I-Type
	    3'b000: Imm = {{(DWIDTH-12){inst[DWIDTH-8]}},inst[DWIDTH-8:13]}; 
	// S-Type
	    3'b001: Imm = {{(DWIDTH-12){inst[DWIDTH-8]}},inst[DWIDTH-8:18],inst[4:0]}; 
	// SB-Type
	    3'b010: Imm = {{(DWIDTH-12){inst[DWIDTH-8]}},inst[0],inst[DWIDTH-9:18],inst[4:1],1'b0}; 
	// U-Type    
	    3'b011: Imm = {inst[DWIDTH-8:5],12'b0};
	// UJ-Type  
	    3'b100: Imm = {{(DWIDTH-20){inst[DWIDTH-8]}},inst[DWIDTH-8],inst[12:5],inst[13],inst[DWIDTH-9:14],1'b0};
	    
	    default: Imm = 'hz;
	endcase

endmodule
