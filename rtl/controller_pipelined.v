module controller_pipelined #(parameter AWIDTH=32, DWIDTH=32 )
(	input			BrEq,
	input			BrLT,
	input	[DWIDTH-1:0]	inst_x,
	input	[DWIDTH-1:0]	inst_m,
	input	[DWIDTH-1:0]	inst_w,
	
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
			
	wire [4:0] opcode_x,opcode_m,opcode_w;
	wire [2:0] func3_x,func3_m,func3_w;
	wire BrTrue;
	assign opcode_x = inst_x [6:2];
	assign func3_x  = inst_x [14:12];
	assign opcode_m = inst_m [6:2];
	assign func3_m  = inst_m [14:12];
	assign opcode_w = inst_w [6:2];
	assign func3_w  = inst_w [14:12];
	
	//assign func7[5] = inst [30];
	
	/////////////////// IE - stage ///////////////////
	assign BrTrue	= (func3_x[2]&func3_x[0])? (BrEq || !BrLT)
			: (func3_x[2]&!func3_x[0])? BrLT
			:  func3_x[0]?		!BrEq
			:			BrEq;
	
	assign BrUn	= func3_x[2] & func3_x[1];
	assign ALUSel 	= (opcode_x==rtype1||opcode_x==rtype2)?{inst_x[30],func3_x} 
			: (opcode_x==itype3)?			{1'b0,func3_x}
			:					4'b0;
	assign ASel 	= (opcode_x==sbtype||opcode_x==utype1||opcode_x==ujtype);
	assign BSel	= !(opcode_x==rtype1||opcode_x==rtype2);		
				
	assign ImmSel 	= (opcode_x==stype)?			3'b001
			: (opcode_x==sbtype)?			3'b010
			: (opcode_x==utype1||opcode_x==utype2)? 3'b011
			: (opcode_x==ujtype)?			3'b100
			:					3'b000;
	
	/////////////////// MEM - stage ///////////////////
	assign MemRW	= (opcode_m==stype);
	assign Size	= func3_m;
	
	/////////////////// WB - stage ///////////////////	 
	assign WBSel	= (opcode_w==utype2)?			2'b11
			: (opcode_w==itype1)?			2'b00
			: (opcode_w==ujtype||opcode_w==itype5)? 2'b10
			:					2'b01;
	assign RegWEn	= !(opcode_w==sbtype||opcode_w==stype);
	
	//////////////// depends on branch//////
	assign PCSel	= (opcode_x==sbtype)? BrTrue : opcode_x[4]; 
	
endmodule 
