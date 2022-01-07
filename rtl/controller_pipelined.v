module controller_pipelined #(parameter AWIDTH=32, DWIDTH=32 )
(	
	input			BrEq, BrLT,
	input	[DWIDTH-1:0]	inst_x,
	input	[DWIDTH-1:0]	inst_m,
	input	[DWIDTH-1:0]	inst_w,
	
	output	           	PCSel,
	output		[2:0]	ImmSel,
	output  		RegWEn,
	output  		BrUn,
	output  		ASel, BSel,
	output  	[1:0]	AfSel, BfSel,
	output		[3:0]	ALUSel,
	output			MemRW,
	output		[1:0]	WBSel,
	output			stall,
	output			flush,
	output		[2:0]	Size
);
	// instruction types based on opcode
	localparam	rtype1 = 7'b0110011, rtype2 = 7'b0111011, 
			itype1 = 7'b0000011, itype2 = 7'b0001111,
			itype3 = 7'b0010011, itype4 = 7'b0011011,
			itype5 = 7'b1100111, itype6 = 7'b1110011,
			stype  = 7'b0100011, sbtype = 7'b1100011,
			utype1 = 7'b0010111, utype2 = 7'b0110111,
			ujtype = 7'b1101111;
			
	wire [6:0] opcode_x,opcode_m,opcode_w;
	wire [2:0] func3_x,func3_m,func3_w;
	wire BrTrue;
	assign opcode_x = inst_x [6:0];
	assign func3_x  = inst_x [14:12];
	assign opcode_m = inst_m [6:0];
	assign func3_m  = inst_m [14:12];
	assign opcode_w = inst_w [6:0];
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
	assign PCSel	= (opcode_x==sbtype)? BrTrue : opcode_x[6];
 
	//////////////// Forwarding muxer selection//////
	//wire x_have_rs1 = !(opcode_x==utype1||opcode_x==utype2||opcode_x==ujtype)&&!(opcode_x==0);
	//wire x_have_rs2 = (opcode_x==rtype1||opcode_x==rtype2||opcode_x==stype||opcode_x==sbtype)&&!(opcode_x==0);
	wire w_have_rd,m_have_rd; 
	assign m_have_rd  = !(opcode_m==sbtype||opcode_m==stype)&&!(&inst_m[11:7]);
	assign w_have_rd  = !(opcode_w==sbtype||opcode_w==stype)&&!(&inst_w[11:7]);
	
	assign AfSel 	= (m_have_rd&&(inst_x[19:15]==inst_m[11:7]))?	2'b01 // rs1_x=rd_m;
			: (w_have_rd&&(inst_x[19:15]==inst_w[11:7]))?	2'b10 // rs1_x=rd_w;
			:						2'b00; 
	assign BfSel 	= (m_have_rd&&(inst_x[24:20]==inst_m[11:7]))?	2'b01
			: (w_have_rd&&(inst_x[24:20]==inst_w[11:7]))?	2'b10
			:						2'b00;
	//////////////// stalling signal for load type//////
	assign stall 	= m_have_rd&&(inst_x[19:15]==inst_m[11:7]||inst_x[24:20]==inst_m[11:7])&(opcode_m==itype1); // rs1_x=rd_m; 
	
	//////////////// flushing for taken branch//////
	assign flush 	= (BrTrue&&(opcode_x==sbtype))||(opcode_x==ujtype)||(opcode_x==itype5); // rs1_x=rd_m; 

endmodule 
