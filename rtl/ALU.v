module ALU #(parameter DWIDTH=32)
(
	input		[DWIDTH-1:0]	in_a,
	input 		[DWIDTH-1:0]	in_b,
	input 		[3:0]		ALUSel,
	output reg	[DWIDTH-1:0]	alu_out
);

always@*
	case(ALUSel[2:0])
	    3'b000: alu_out = ALUSel[3]? (in_a - in_b) : (in_a + in_b) ;	//add, sub
	    3'b001: alu_out = in_a << in_b;					//sll, shift left logical
	    3'b010: alu_out = ($signed(in_a) < $signed(in_b))? 1:0;   	//slt, set less than
	    3'b011: alu_out = in_a < in_b;					//sltu, set less than unsigned
	    3'b100: alu_out = in_a ^ in_b;					//bitwise xor
	    3'b101: alu_out = ALUSel[3]? $signed($signed(in_a) >>> in_b):(in_a >> in_b);	//srl, sra
	    3'b110: alu_out = in_a | in_b;            			//bitwise or
	    3'b111: alu_out = in_a & in_b;             			//bitwise and
	    default: alu_out = 'hz;
	endcase

endmodule
