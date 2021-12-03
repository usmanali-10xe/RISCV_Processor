module RISCV_Processor_pipelined #(parameter DWIDTH=32, AWIDTH=32, IWIDTH=32, RAWIDTH=5)
(	input clk,
	input rst
);

	wire [DWIDTH-1:0] pc_in, pc_out, pc_out_d, pc_out_x, pc_out_m, pc_out_w;// PC signal
	wire [DWIDTH-1:0] pc_out_new, pc_out_m_new;				// updated PC
	wire [IWIDTH-1:0] inst, inst_d, inst_x, inst_m, inst_w;			// data signals
	
	wire [DWIDTH-1:0] DataA, DataA_x, DataA_fx;					// DataA signal
	wire [DWIDTH-1:0] DataB, DataB_x, DataB_fx, DataB_m;				// DataB signal
	wire [DWIDTH-1:0] imm_x, imm_m, imm_w;					// immediate

	wire [DWIDTH-1:0] in_a, in_b; 						// alu inputs(A's, B's mux out)
	wire [DWIDTH-1:0] alu_out, alu_out_m, alu_out_w;			// alu_out signal
	wire [DWIDTH-1:0] mem, mem_w;							// data from memory
	wire [DWIDTH-1:0] wb;							// write back data

	wire [3:0] ALUSel;							// ALU selection			
	wire [1:0] WBSel;
	wire [2:0]ImmSel;

	wire MemRW;								// RW DMEM selection
	wire [2:0]  Size;							// data size to be RW	
	wire PCSel;								// PC Selection for branch
	wire BSel, ASel;							// A d B data selection
	wire [1:0] BfSel, AfSel;						// A and B data forward selection
	wire BrUn, BrEq, BrLT;							// BrComp in out signals
	wire RegWEn;								// Reg write enable
	wire stall;
// PC
	register pc(.clk(clk), .rst(rst), .load(!stall), .data_in(pc_in), .data_out(pc_out));
// next PC
	assign pc_out_new = pc_out + 32'd4;
// PCSel_mux
	Mux2 pc_mux(.sel(PCSel), .in0(pc_out_new), .in1(alu_out), .mux_out(pc_in));
// IMEM
	IMEM im(.clk(clk), .ILoad(1'b0), .IAddr(pc_out), .inst(inst), .instW(32'b0));
//*********ID register*********//
	register ID_inst(.clk(clk), .rst(rst), .load(!stall), .data_in(inst), .data_out(inst_d));
	register ID_pc(.clk(clk), .rst(rst), .load(!stall), .data_in(pc_out), .data_out(pc_out_d));
// REGFILE
	RegFile rfile(.clk(clk) , .RegWEn(RegWEn), .AddrA(inst_d[19:15]), .AddrB(inst_d[24:20]), .AddrD(inst_w[11:7]), .DataD(wb) , .DataA (DataA), .DataB (DataB));
//*********IE register*********//
	register IE_DataA(.clk(clk), .rst(rst), .load(!stall), .data_in(DataA), .data_out(DataA_x));
	register IE_DataB(.clk(clk), .rst(rst), .load(!stall), .data_in(DataB), .data_out(DataB_x));
	register IE_pc(.clk(clk), .rst(rst), .load(!stall), .data_in(pc_out_d), .data_out(pc_out_x));
	register IE_inst(.clk(clk), .rst(rst), .load(!stall), .data_in(inst_d), .data_out(inst_x));
// BranchComp
	BranchComp br_cmp(.BrUn(BrUn), .BrA(DataA_x), .BrB(DataB_x), .BrEq(BrEq), .BrLT(BrLT));
// ImmGen
	ImmGen imgen(.inst(inst_x[IWIDTH-1:7]), .ImmSel(ImmSel), .Imm(imm_x));
// BSel_mux
	Mux4 b_forward_mux(.sel(BfSel), .in0(DataB_x), .in1(alu_out_m), .in2(wb), .in3(32'b0), .mux_out(DataB_fx));
	Mux2 b_mux (.sel(BSel), .in0(DataB_fx), .in1(imm_x), .mux_out(in_b));
// ASel_mux
	Mux4 a_forward_mux(.sel(AfSel), .in0(DataA_x), .in1(alu_out_m), .in2(wb), .in3(32'b0), .mux_out(DataA_fx));
	Mux2 a_mux (.sel(ASel), .in0(DataA_fx), .in1(pc_out_x), .mux_out(in_a));
// ALU
	ALU alu(.in_a(in_a), .in_b(in_b), .ALUSel(ALUSel), .alu_out(alu_out));
//*********MEM register*********//
	register MEM_alu_out(.clk(clk), .rst(rst), .load(1'b1), .data_in(alu_out), .data_out(alu_out_m));
	register MEM_DataB(.clk(clk), .rst(rst), .load(1'b1), .data_in(DataB_fx), .data_out(DataB_m));
	register MEM_pc(.clk(clk), .rst(rst), .load(1'b1), .data_in(pc_out_x), .data_out(pc_out_m));
	register MEM_inst(.clk(clk), .rst(rst), .load(1'b1), .data_in(inst_x), .data_out(inst_m));
	register MEM_imm(.clk(clk), .rst(rst), .load(1'b1), .data_in(imm_x), .data_out(imm_m));
// DMEM
	DMEM dmemo(.clk(clk), .Size(Size), .MemRW(MemRW), .Addr(alu_out_m),  .DataW(DataB_m),  .DataR(mem));
// new PC for WB
	assign pc_out_m_new = pc_out_m + 32'd4;
//*********WB register*********//
	register WB_alu_out(.clk(clk), .rst(rst), .load(1'b1), .data_in(alu_out_m), .data_out(alu_out_w));
	register WB_mem(.clk(clk), .rst(rst), .load(1'b1), .data_in(mem), .data_out(mem_w));
	register WB_pc(.clk(clk), .rst(rst), .load(1'b1), .data_in(pc_out_m_new), .data_out(pc_out_w));
	register WB_inst(.clk(clk), .rst(rst), .load(1'b1), .data_in(inst_m), .data_out(inst_w));
	register WB_imm(.clk(clk), .rst(rst), .load(1'b1), .data_in(imm_m), .data_out(imm_w));
// WbSel_mux 
	Mux4 wb_mux(.sel(WBSel), .in0(mem_w), .in1(alu_out_w), .in2(pc_out_w), .in3(imm_w), .mux_out(wb));
// Controller
	controller_pipelined control (.BrEq(BrEq), .BrLT(BrLT), .inst_x(inst_x), .inst_m(inst_m),.inst_w(inst_w),  .PCSel(PCSel),  .ImmSel(ImmSel),
		                 .RegWEn(RegWEn),  .BrUn(BrUn), .ASel(ASel), .BSel(BSel), .AfSel(AfSel), .BfSel(BfSel), .ALUSel(ALUSel),
		                 .MemRW(MemRW), .WBSel(WBSel), .Size(Size), .stall(stall), .flush(flush));

endmodule
