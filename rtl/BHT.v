module BHT
 (
	input				clk,
	input				rst,
	input				Br_x,
	input				BrTrue,
	output				BrPred
 );
    localparam                  [1:0] SNT  = 2'b00;          //Strong NT
    localparam                  [1:0] WNT  = 2'b01;          //Weak NT
    localparam                  [1:0] WT   = 2'b10;          //Weak T
    localparam                  [1:0] ST   = 2'b11;          //Strong T
    reg                         [1:0] current_state;         //Current State of FSM
    reg                         [1:0]    next_state;         //Next State of FSM

 always @(posedge clk)
    if(rst)
        current_state <= SNT; // Reset State
    else
        current_state <= next_state; // next state calculated by combinational always block

 always @(*)
 begin
    case(current_state) // condtion for current state
        SNT : 
                next_state <= Br_x&&BrTrue? WNT:SNT;
        WNT: 
                next_state <= Br_x&&BrTrue? WT:SNT;
        WT: 
                next_state <= Br_x&&BrTrue? ST:WNT;
        ST : 
                next_state <= Br_x&&BrTrue? ST:WT;      	
	default:
                next_state <= current_state;
    endcase
 end
	//output
 assign BrPred = (next_state==WT||next_state==ST)? 1'b1:1'b0;
endmodule 