module RISCV_Processor #(parameter DWIDTH=32, AWIDTH=32, IWIDTH=32, RAWIDTH=5)
(	input clk,
	input rst
);
//PC
	wire [DWIDTH-1:0]pc_in;
	wire [DWIDTH-1:0]pc_out;
	register pc(.clk(clk), .rst(rst), .load(1'b1), .data_in(pc_in), .data_out(pc_out));
//next PC
	wire   [DWIDTH-1:0] pc_out_new;
	assign pc_out_new = pc_out + 32'd4;
//IMEM
	wire [IWIDTH-1:0] inst;
	IMEM im(.clk(clk), .ILoad(1'b0), .IAddr(pc_out), .instW(32'b0), .inst(inst));
//REGFILE
	wire RegWEn;
	wire [DWIDTH-1:0] wb;
	wire [DWIDTH-1:0] DataA,DataB;
	RegFile rfile(.clk(clk) , .RegWEn(RegWEn), .AddrA(inst[19:15]), .AddrB(inst[24:20]), .AddrD(inst[11:7]), .DataD(wb) , .DataA (DataA), .DataB (DataB));
//BranchComp
	wire BrUn, BrEq, BrLT;
	BranchComp br_cmp(.BrUn(BrUn), .BrA(DataA), .BrB(DataB), .BrEq(BrEq), .BrLT(BrLT));
//ImmGen
	wire [2:0]ImmSel;
	wire [DWIDTH-1:0] imm;
	ImmGen imgen(.inst(inst[IWIDTH-1:7]), .ImmSel(ImmSel), .Imm(imm));
//ALU
	wire [DWIDTH-1:0] in_a, in_b, alu_out;
	wire [3:0] ALUSel;
	ALU alu(.in_a(in_a), .in_b(in_b), .ALUSel(ALUSel), .alu_out(alu_out));
//DMEM
	wire MemRW;
	wire [DWIDTH-1:0] mem;
	wire [2:0]  Size;
	DMEM dmemo(.clk(clk), .Size(Size), .MemRW(MemRW), .Addr(alu_out),  .DataW(DataB),  .DataR(mem));
//Muxes
	wire PCSel, BSel, ASel;
	wire [1:0] WBSel;
	Mux2 pc_mux(.sel(PCSel),	.in0(pc_out_new),	.in1(alu_out),	.mux_out(pc_in));
	Mux2 b_mux (.sel(BSel),	.in0(DataB),	.in1(imm),	.mux_out(in_b));
	Mux2 a_mux (.sel(ASel),	.in0(DataA),	.in1(pc_out),	.mux_out(in_a));
	Mux4 wb_mux(.sel(WBSel),	.in0(mem),	.in1(alu_out),	.in2(pc_out_new), .in3(imm), .mux_out(wb));

//Controller
	controller control (.BrEq(BrEq), .BrLT(BrLT), .inst(inst),  .PCSel(PCSel),  .ImmSel(ImmSel),
		                 .RegWEn(RegWEn),  .BrUn(BrUn), .ASel(ASel), .BSel(BSel), .ALUSel(ALUSel),
		                 .MemRW(MemRW), .WBSel(WBSel), .Size(Size));

endmodule
