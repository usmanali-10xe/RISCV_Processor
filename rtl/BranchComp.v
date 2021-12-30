module BranchComp #(parameter DWIDTH=32)
 (
	input				BrUn,
	input		[DWIDTH-1:0]	BrA,
	input		[DWIDTH-1:0]	BrB,
	output   			BrEq,
	output   			BrLT
 );
	
	assign	BrEq = (BrA==BrB);  
	assign	BrLT = BrUn? (BrA<BrB) : ($signed(BrA)<$signed(BrB));  
			
endmodule

