
`default_nettype none
`include "common.h"

module execute_debugger(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Debugger Port
		input wire iDEBUG_CTRL_REQ,
		input wire iDEBUG_CTRL_STOP,
		input wire iDEBUG_CTRL_START,
		output wire [31:0] oDEBUG_CTRL_ACK,
		output wire [31:0] oDEBUG_REG_OUT_FLAGR,
		//Pipeline
		output wire oPIPELINE_STOP,
		//Registers
		input wire [4:0] iREGISTER_FLAGR,
		//Busy
		input wire iBUSY
	);

	localparam L_PARAM_DEBUG_IDLE = 2'h0;
	localparam L_PARAM_DEBUG_START_REQ = 2'h1;
	localparam L_PARAM_DEBUG_STOP_REQ = 2'h2;

	//Debugger
	reg [1:0] b_debug_state;
	reg b_debug_stop;
	reg b_debug_cmd_ack;

	//Debug Module Enable
	`ifdef MIST1032ISA_STANDARD_DEBUGGER
		always@(posedge iCLOCK or negedge inRESET)begin
			if(!inRESET)begin
				b_debug_state <= L_PARAM_DEBUG_IDLE;
				b_debug_stop <= 1'b0;
				b_debug_cmd_ack <= 1'b0;
			end
			else if(iRESET_SYNC)begin
				b_debug_state <= L_PARAM_DEBUG_IDLE;
				b_debug_stop <= 1'b0;
				b_debug_cmd_ack <= 1'b0;
			end
			else begin
				case(b_debug_state)
					L_PARAM_DEBUG_IDLE:
						begin
							b_debug_cmd_ack <= 1'b0;
							if(iDEBUG_CTRL_REQ && iDEBUG_CTRL_STOP)begin
								b_debug_state <= L_PARAM_DEBUG_START_REQ;
							end
							else if(iDEBUG_CTRL_REQ && iDEBUG_CTRL_START)begin
								b_debug_state <= L_PARAM_DEBUG_STOP_REQ;
							end
						end
					L_PARAM_DEBUG_START_REQ:
						begin
							b_debug_stop <= 1'b0;
							b_debug_cmd_ack <= 1'b1;
							b_debug_state <= L_PARAM_DEBUG_IDLE;
						end
					L_PARAM_DEBUG_STOP_REQ:
						begin
							if(!iBUSY)begin
								b_debug_stop <= 1'b1;
								b_debug_cmd_ack <= 1'b1;
								b_debug_state <= L_PARAM_DEBUG_IDLE;
							end
						end
				endcase
			end
		end
	`else
		always@(posedge iCLOCK or negedge inRESET)begin
			if(!inRESET)begin
				b_debug_state <= L_PARAM_DEBUG_IDLE;
				b_debug_stop <= 1'b0;
				b_debug_cmd_ack <= 1'b0;
			end
			else if(iRESET_SYNC)begin
				b_debug_state <= L_PARAM_DEBUG_IDLE;
				b_debug_stop <= 1'b0;
				b_debug_cmd_ack <= 1'b0;
			end
			else begin
				b_debug_state <= b_debug_state;
				b_debug_stop <= b_debug_stop;
				b_debug_cmd_ack <= b_debug_cmd_ack;
			end
		end
	`endif

	//Debug Module Enable
	`ifdef MIST1032ISA_STANDARD_DEBUGGER
		assign oDEBUG_CTRL_ACK = b_debug_cmd_ack;
		assign oDEBUG_REG_OUT_FLAGR = {27'h0, iREGISTER_FLAGR};
	`else
	//Disable
		assign oDEBUG_CTRL_ACK = 32'h0;
		assign oDEBUG_REG_OUT_FLAGR = 32'h0;
	`endif


	assign oPIPELINE_STOP = b_debug_stop;


endmodule // execute_debugger


`default_nettype wire 


