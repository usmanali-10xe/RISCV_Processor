module RISCV_Processor #(parameter DWIDTH=32, AWIDTH=32, IWIDTH=32, RAWIDTH=5)
(	input clk,
	input rst
);
// PC
	wire [DWIDTH-1:0] pc_in;
	wire [DWIDTH-1:0] pc_out;
	register pc(.clk(clk), .rst(rst), .load(1'b1), .data_in(pc_in), .data_out(pc_out));
// next PC
	wire   [DWIDTH-1:0] pc_out_new;
	assign pc_out_new = pc_out + 32'd4;
// IMEM
	wire [IWIDTH-1:0] inst;
	IMEM im(.clk(clk), .ILoad(1'b0), .IAddr(pc_out), .instW(32'b0), .inst(inst));
//*********ID register*********//
	wire [IWIDTH-1:0] inst_d;
	wire [DWIDTH-1:0] pc_out_d;
	register ID_inst(.clk(clk), .rst(rst), .load(1'b1), .data_in(inst), .data_out(inst_d));
	register ID_pc(.clk(clk), .rst(rst), .load(1'b1), .data_in(pc_out), .data_out(pc_out_d));
// REGFILE
	wire RegWEn;
	wire [DWIDTH-1:0] wb;
	wire [DWIDTH-1:0] DataA,DataB;
	RegFile rfile(.clk(clk) , .RegWEn(RegWEn), .AddrA(inst_d[19:15]), .AddrB(inst_d[24:20]), .AddrD(inst_w[11:7]), .DataD(wb) , .DataA (DataA), .DataB (DataB));
//*********IE register*********//
	wire [DWIDTH-1:0] DataA_x,DataB_x;
	wire [IWIDTH-1:0] inst_x;
	wire [DWIDTH-1:0] pc_out_x;
	register IE_DataA(.clk(clk), .rst(rst), .load(1'b1), .data_in(DataA), .data_out(DataA_x));
	register IE_DataB(.clk(clk), .rst(rst), .load(1'b1), .data_in(DataB), .data_out(DataB_x));
	register IE_pc(.clk(clk), .rst(rst), .load(1'b1), .data_in(pc_out_d), .data_out(pc_out_x));
	register IE_inst(.clk(clk), .rst(rst), .load(1'b1), .data_in(inst_d), .data_out(inst_x));
// BranchComp
	wire BrUn, BrEq, BrLT;
	BranchComp br_cmp(.BrUn(BrUn), .BrA(DataA_x), .BrB(DataB_x), .BrEq(BrEq), .BrLT(BrLT));
// ImmGen
	wire [2:0]ImmSel;
	wire [DWIDTH-1:0] imm_x;
	ImmGen imgen(.inst(inst_x[IWIDTH-1:7]), .ImmSel(ImmSel), .Imm(imm_x));
// BSel_mux
	wire BSel;
	Mux2 b_mux (.sel(BSel), .in0(DataB_x), .in1(imm_x), .mux_out(in_b));
// ASel_mux
	wire ASel;
	Mux2 a_mux (.sel(ASel), .in0(DataA_x), .in1(pc_out_x), .mux_out(in_a));
// ALU
	wire [DWIDTH-1:0] in_a, in_b, alu_out;
	wire [3:0] ALUSel;
	ALU alu(.in_a(in_a), .in_b(in_b), .ALUSel(ALUSel), .alu_out(alu_out));
//*********MEM register*********//
	wire [DWIDTH-1:0] alu_out_m,DataB_m;
	wire [IWIDTH-1:0] inst_m;
	wire [DWIDTH-1:0] pc_out_m;
	register MEM_alu_out(.clk(clk), .rst(rst), .load(1'b1), .data_in(alu_out), .data_out(alu_out_m));
	register MEM_DataB(.clk(clk), .rst(rst), .load(1'b1), .data_in(DataB_x), .data_out(DataB_m));
	register MEM_pc(.clk(clk), .rst(rst), .load(1'b1), .data_in(pc_out_x), .data_out(pc_out_m));
	register MEM_inst(.clk(clk), .rst(rst), .load(1'b1), .data_in(inst_x), .data_out(inst_m));
	register MEM_imm(.clk(clk), .rst(rst), .load(1'b1), .data_in(imm_x), .data_out(imm_m));
// DMEM
	wire MemRW;
	wire [DWIDTH-1:0] mem;
	wire [2:0]  Size;
	DMEM dmemo(.clk(clk), .Size(Size), .MemRW(MemRW), .Addr(alu_out_m),  .DataW(DataB_m),  .DataR(mem));
// new PC for WB
	wire   [DWIDTH-1:0] pc_out_m_new;
	assign pc_out_m_new = pc_out_m + 32'd4;
//*********WB register*********//
	wire [DWIDTH-1:0] alu_out_w, mem_w;
	wire [IWIDTH-1:0] inst_w;
	wire [DWIDTH-1:0] pc_out_w;
	register WB_alu_out(.clk(clk), .rst(rst), .load(1'b1), .data_in(alu_out_m), .data_out(alu_out_w));
	register WB_mem(.clk(clk), .rst(rst), .load(1'b1), .data_in(mem), .data_out(mem_w));
	register WB_pc(.clk(clk), .rst(rst), .load(1'b1), .data_in(pc_out_m_new), .data_out(pc_out_w));
	register WB_inst(.clk(clk), .rst(rst), .load(1'b1), .data_in(inst_m), .data_out(inst_w));
	register WB_imm(.clk(clk), .rst(rst), .load(1'b1), .data_in(imm_m), .data_out(imm_w));
// WbSel_mux 
	wire [1:0] WBSel;
	Mux4 wb_mux(.sel(WBSel), .in0(mem_w), .in1(alu_out_w), .in2(pc_out_w), .in3(imm_w), .mux_out(wb));
// PCSel_mux
	wire PCSel;
	Mux2 pc_mux(.sel(PCSel), .in0(pc_out_new), .in1(alu_out), .mux_out(pc_in));

// Controller
	controller control (.BrEq(BrEq), .BrLT(BrLT), .inst(inst),  .PCSel(PCSel),  .ImmSel(ImmSel),
		                 .RegWEn(RegWEn),  .BrUn(BrUn), .ASel(ASel), .BSel(BSel), .ALUSel(ALUSel),
		                 .MemRW(MemRW), .WBSel(WBSel), .Size(Size));

endmodule
