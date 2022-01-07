module BTB #(parameter AWIDTH=32, DWIDTH=32)
 (
	input				clk,
	input				rst,
	input				Br_x,
	input				Br_f,
	input		[AWIDTH-1:0]	PC_f,
	input		[AWIDTH-1:0]	PC_x,
	input		[AWIDTH-1:0]	alu_out,
	output				Target_valid,
	output 		[DWIDTH-1:0]	BrTarget
 );
	reg	[2*DWIDTH:0]	Targets[0:3];
	reg	[2*DWIDTH:0]	Entry;

// reading the table and finding target
 always@(*)
 begin
	case (PC_f[3:2])
	2'b00: 
		Entry = Targets[0];
	2'b01: 
		Entry = Targets[1];
	2'b10: 
		Entry = Targets[2];
	2'b11: 
		Entry = Targets[3];
	endcase
 end
// checking valid bit, Tag and if the fetched inst is branch type
	assign BrTarget = Entry[DWIDTH-1:0];
	assign Target_valid= Entry[2*DWIDTH]&&(Entry[2*DWIDTH-1:DWIDTH]==PC_f);
// writing target table on clock edge
 always@(posedge clk)
 begin
   if(rst) begin
		Targets[0] = 0; //clearing valid bit
		Targets[1] = 0; //clearing valid bit
		Targets[2] = 0; //clearing valid bit
		Targets[3] = 0; //clearing valid bit
	end
	else if(Br_x) // checking if executed inst is bracnh type: update the target table
	case (PC_x[3:2])
	2'b00: 
		Targets[0] = {1'b1,PC_x,alu_out};
	2'b01: 
		Targets[1] = {1'b1,PC_x,alu_out};
	2'b10: 
		Targets[2] = {1'b1,PC_x,alu_out};
	2'b11: 
		Targets[3] = {1'b1,PC_x,alu_out};
	endcase
 end

endmodule 