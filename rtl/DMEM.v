module DMEM #(parameter AWIDTH=32, DWIDTH=32)
 (
  input                 clk  ,
  input  [2:0]          Size,
  input                 MemRW,
  input  [AWIDTH-1:0]   Addr ,
  input  [DWIDTH-1:0]   DataW  ,
  output reg [DWIDTH-1:0]   DataR
 );
  localparam  addressable_bits=8;
  reg [addressable_bits-1:0] dmemory [511:0];
  always @(posedge clk) begin
    if (MemRW) begin
      case (Size[1:0])
        //Store Byte
        2'b00: begin
          dmemory[Addr] = DataW[7:0];
        end
        //Store Half Word
        2'b01: begin
          dmemory[Addr+1] = DataW[15:8];
          dmemory[Addr+0] = DataW[7:0];
        end
        //Store Word
        2'b10: begin
          dmemory[Addr+3] = DataW[31:24];
          dmemory[Addr+2] = DataW[23:16];
          dmemory[Addr+1] = DataW[15:8];
          dmemory[Addr+0] = DataW[7:0];
        end
        //Store Double Word (Not to be implemented yet)
        2'b11: begin
        end
      endcase
    end
  end
  always @ (*) begin
    case (Size)
        //Load Byte
        3'b000: begin
          DataR[7:0] = dmemory[Addr];
          DataR[15:8] = {addressable_bits{DataR[7]}};
          DataR[23:16] = {addressable_bits{DataR[7]}};
          DataR[31:24] = {addressable_bits{DataR[7]}};
        end
        //Load Half Word
        3'b001: begin
          DataR[7:0] = dmemory[Addr+0];
          DataR[15:8] = dmemory[Addr+1];
          DataR[23:16] = {addressable_bits{DataR[15]}};
          DataR[31:24] = {addressable_bits{DataR[15]}};
        end
        3'b010: begin
          DataR[7:0] = dmemory[Addr+0];
          DataR[15:8] = dmemory[Addr+1];
          DataR[23:16] = dmemory[Addr+2];
          DataR[31:24] = dmemory[Addr+3];
        end
        //Load Double Word Signed (Not to be implemented yet)
        3'b011: begin
          DataR[7:0] = dmemory[Addr+0];
          DataR[15:8] = dmemory[Addr+1];
          DataR[23:16] = dmemory[Addr+2];
          DataR[31:24] = dmemory[Addr+3];
        end

        //Load Byte unSigned
        3'b100: begin
          DataR[7:0] = dmemory[Addr];
          DataR[15:8] = {addressable_bits{1'b0}};
          DataR[23:16] = {addressable_bits{1'b0}};
          DataR[31:24] = {addressable_bits{1'b0}};
        end
        //Load Half Word unSigned
        3'b101: begin
          DataR[7:0] = dmemory[Addr+0];
          DataR[15:8] = dmemory[Addr+1];
          DataR[23:16] = {addressable_bits{1'b0}};
          DataR[31:24] = {addressable_bits{1'b0}};
        end
	// Load Word unSigned
        3'b110: begin 
          DataR[7:0] = dmemory[Addr+0];
          DataR[15:8] = dmemory[Addr+1];
          DataR[23:16] = dmemory[Addr+2];
          DataR[31:24] = dmemory[Addr+3];
        end
        //Load Double Word unSigned (Not to be implemented yet)
        3'b111: begin
          DataR[7:0] = dmemory[Addr+0];
          DataR[15:8] = dmemory[Addr+1];
          DataR[23:16] = dmemory[Addr+2];
          DataR[31:24] = dmemory[Addr+3];
        end
    endcase
  end
endmodule 