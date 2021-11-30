module controller #(parameter AWIDTH=32, DWIDTH=32 )
(	input			BrEq,
	input			BrLT,
	input	[DWIDTH-1:0]	inst,
	output	           	PCSel,
	output		[2:0]	ImmSel,
	output  		RegWEn,
	output  		BrUn,
	output  		ASel,
	output  		BSel,
	output		[3:0]	ALUSel,
	output			MemRW,
	output		[1:0]	WBSel,
	output		[2:0]	Size
);
	// instruction types based on opcode
	localparam	rtype1 = 5'b01100, rtype2 = 5'b01110, 
			itype1 = 5'b00000, itype2 = 5'b00011,
			itype3 = 5'b00100, itype4 = 5'b00110,
			itype5 = 5'b11001, itype6 = 5'b11100,
			stype  = 5'b01000, sbtype = 5'b11000,
			utype1 = 5'b00101, utype2 = 5'b01101,
			ujtype = 5'b11011;
	// for operation states
	//localparam [2:0]add=0,sll=1,slt=2,sltu=3,bit_xor=4,srl=5,sra=6,bit_or=7,bit_and=8;
			
	wire [4:0] opcode;
	wire [2:0] func3;
	wire [6:0] func7;
	wire BrTrue;
		

	assign opcode	= inst [6:2];
	assign func3 	= inst [14:12];
	assign func7 	= inst [31:25];
	
	assign BrTrue	= (func3[2]&func3[0])? (BrEq || !BrLT)
			: (func3[2]&!func3[0])? BrLT
			:  func3[0]?		!BrEq
			:			BrEq;
	
	assign BrUn	= func3[2] & func3[1];
	assign PCSel	= (opcode==sbtype)? BrTrue : opcode[4];  
	assign ALUSel 	= (opcode==rtype1||opcode==rtype2)? {func7[5],func3} 
			: (opcode==itype3)? 		    {1'b0,func3}
			:					4'b0;
	assign ImmSel 	= (opcode==stype)?			3'b001
			: (opcode==sbtype)?			3'b010
			: (opcode==utype1||opcode==utype2)?	3'b011
			: (opcode==ujtype)?			3'b100
			:					3'b000;
	assign ASel 	= (opcode==sbtype||opcode==utype1||opcode==ujtype);
	assign BSel	= !(opcode==rtype1||opcode==rtype2);
	assign WBSel	= (opcode==utype2)?			2'b11
			: (opcode==itype1)?			2'b00
			: (opcode==ujtype||opcode==itype5)?	2'b10
			:					2'b01;
	assign RegWEn	= !(opcode==sbtype||opcode==stype);
	assign MemRW	= (opcode==stype);
	assign Size	= func3;
endmodule 
