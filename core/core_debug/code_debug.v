`include "processor.h"
`default_nettype none

module core_debug(
		input iCLOCK,
		input inRESET,
		//CMD
		input iCMD_REQ,
		output oCMD_BUSY,
		input [3:0] iCMD_COMMAND,
		input [11:0] iCMD_TARGET,
		input [31:0] iCMD_DATA,
		//Response
		output oRESP_VALID,
		output oRESP_ERROR,
		output [31:0] oRESP_DATA,
		//System control
		output oDEBUG_CORE_REQ,
		output oDEBUG_CORE_STOP,
		output oDEBUG_CORE_START,
		input iDEBUG_CORE_ACK,
		//Register Read
		input [31:0] iREG_R_GR0,
		input [31:0] iREG_R_GR1,
		input [31:0] iREG_R_GR2,
		input [31:0] iREG_R_GR3,
		input [31:0] iREG_R_GR4,
		input [31:0] iREG_R_GR5,
		input [31:0] iREG_R_GR6,
		input [31:0] iREG_R_GR7,
		input [31:0] iREG_R_GR8,
		input [31:0] iREG_R_GR9,
		input [31:0] iREG_R_GR10,
		input [31:0] iREG_R_GR11,
		input [31:0] iREG_R_GR12,
		input [31:0] iREG_R_GR13,
		input [31:0] iREG_R_GR14,
		input [31:0] iREG_R_GR15,
		input [31:0] iREG_R_GR16,
		input [31:0] iREG_R_GR17,
		input [31:0] iREG_R_GR18,
		input [31:0] iREG_R_GR19,
		input [31:0] iREG_R_GR20,
		input [31:0] iREG_R_GR21,
		input [31:0] iREG_R_GR22,
		input [31:0] iREG_R_GR23,
		input [31:0] iREG_R_GR24,
		input [31:0] iREG_R_GR25,
		input [31:0] iREG_R_GR26,
		input [31:0] iREG_R_GR27,
		input [31:0] iREG_R_GR28,
		input [31:0] iREG_R_GR29,
		input [31:0] iREG_R_GR30,
		input [31:0] iREG_R_GR31,
		input [31:0] iREG_R_FLAGR,
		input [31:0] iREG_R_SPR,
		input [31:0] iREG_R_PCR,
		input [31:0] iREG_R_PPCR,
		input [31:0] iREG_R_PSR,
		input [31:0] iREG_R_PPSR
	);
	
	
	//Command
	localparam CORE_DEBUG_CMD_READ_REG = 4'h0;
	localparam CORE_DEBUG_CMD_WRITE_REG = 4'h1;
	localparam CORE_DEBUG_CMD_GO_CORE = 4'h8;
	localparam CORE_DEBUG_CMD_INTGO_CORE = 4'h9;
	localparam CORE_DEBUG_CMD_SINGLESTEP_CORE = 4'hA;
	localparam CORE_DEBUG_CMD_STOP_CORE = 4'hF;
	
	//Register Target
	localparam CORE_DEBUG_TARGET_GR0 = 12'd0;
	localparam CORE_DEBUG_TARGET_GR1 = 12'd1;
	localparam CORE_DEBUG_TARGET_GR2 = 12'd2;
	localparam CORE_DEBUG_TARGET_GR3 = 12'd3;
	localparam CORE_DEBUG_TARGET_GR4 = 12'd4;
	localparam CORE_DEBUG_TARGET_GR5 = 12'd5;
	localparam CORE_DEBUG_TARGET_GR6 = 12'd6;
	localparam CORE_DEBUG_TARGET_GR7 = 12'd7;
	localparam CORE_DEBUG_TARGET_GR8 = 12'd8;
	localparam CORE_DEBUG_TARGET_GR9 = 12'd9;
	localparam CORE_DEBUG_TARGET_GR10 = 12'd10;
	localparam CORE_DEBUG_TARGET_GR11 = 12'd11;
	localparam CORE_DEBUG_TARGET_GR12 = 12'd12;
	localparam CORE_DEBUG_TARGET_GR13 = 12'd13;
	localparam CORE_DEBUG_TARGET_GR14 = 12'd14;
	localparam CORE_DEBUG_TARGET_GR15 = 12'd15;
	localparam CORE_DEBUG_TARGET_GR16 = 12'd16;
	localparam CORE_DEBUG_TARGET_GR17 = 12'd17;
	localparam CORE_DEBUG_TARGET_GR18 = 12'd18;
	localparam CORE_DEBUG_TARGET_GR19 = 12'd19;
	localparam CORE_DEBUG_TARGET_GR20 = 12'd20;
	localparam CORE_DEBUG_TARGET_GR21 = 12'd21;
	localparam CORE_DEBUG_TARGET_GR22 = 12'd22;
	localparam CORE_DEBUG_TARGET_GR23 = 12'd23;
	localparam CORE_DEBUG_TARGET_GR24 = 12'd24;
	localparam CORE_DEBUG_TARGET_GR25 = 12'd25;
	localparam CORE_DEBUG_TARGET_GR26 = 12'd26;
	localparam CORE_DEBUG_TARGET_GR27 = 12'd27;
	localparam CORE_DEBUG_TARGET_GR28 = 12'd28;
	localparam CORE_DEBUG_TARGET_GR29 = 12'd29;
	localparam CORE_DEBUG_TARGET_GR30 = 12'd30;
	localparam CORE_DEBUG_TARGET_GR31 = 12'd31;
	localparam CORE_DEBUG_TARGET_FLAGR = 12'd32;
	localparam CORE_DEBUG_TARGET_SPR = 12'd33;
	localparam CORE_DEBUG_TARGET_PCR = 12'd34;
	localparam CORE_DEBUG_TARGET_PPCR = 12'd35;
	localparam CORE_DEBUG_TARGET_PSR = 12'd36;
	localparam CORE_DEBUG_TARGET_PPSR = 12'd37;

	
	wire this_busy = b_main_wait || reg_working;
	
	/***************************************************
	//Main State
	***************************************************/
	wire main_command_valid = iCMD_REQ && !this_busy;
	wire [3:0] main_command = iCMD_COMMAND;
	wire main_core_ack = iDEBUG_CORE_ACK;
	
	reg b_main_wait;
	reg b_main_core_stop;
	reg b_main_core_ack;
	generate
		//Debug Module Enable
		if(`PROCESSOR_USE_DEBUG_MODULE)begin
			always@(posedge iCLOCK or negedge inRESET)begin
				if(!inRESET)begin
					b_main_wait <= 1'b0;
					b_main_core_stop <= 1'b0;
					b_main_core_ack <= 1'b0;
				end
				else if(b_main_wait)begin
					b_main_wait <= !main_core_ack;
					b_main_core_ack <= iDEBUG_CORE_ACK;
				end
				else begin
					b_main_core_ack <= 1'b0;
					if(main_command_valid) begin
						case(main_command)
							CORE_DEBUG_CMD_GO_CORE:
								begin
									b_main_wait <= 1'b1;
									b_main_core_stop <= 1'b0;
								end
							CORE_DEBUG_CMD_STOP_CORE:
								begin
									b_main_wait <= 1'b1;
									b_main_core_stop <= 1'b1;
								end
						endcase
					end
				end
			end
		end
		//Disable
		else begin
			always@(posedge iCLOCK or negedge inRESET)begin
				if(!inRESET)begin
					b_main_wait <= 1'b0;
					b_main_core_stop <= 1'b0;
					b_main_core_ack <= 1'b0;
				end
				else begin
					b_main_wait <= b_main_wait;
					b_main_core_stop <= b_main_core_stop;
					b_main_core_ack <= b_main_core_ack;
				end
			end
		end
	endgenerate

	
	
	/***************************************************
	//Register Read State
	***************************************************/
	parameter L_PARAM_REG_READ_STT_IDLE = 1'h0;
	parameter L_PARAM_REG_READ_STT_READEND = 1'h1;
	
	wire reg_working = (b_reg_read_state == L_PARAM_REG_READ_STT_READEND);
	wire reg_read_start = b_main_core_stop && !b_main_wait && (iCMD_COMMAND == CORE_DEBUG_CMD_READ_REG) && iCMD_REQ && !this_busy;
	wire reg_read_end = b_reg_read_end;
	wire [11:0] reg_read_target = iCMD_TARGET;
	reg b_reg_read_state;
	reg [31:0] b_reg_read_r_data;
	reg b_reg_read_end;
	
	generate
		//Debug Module Enable
		if(`PROCESSOR_USE_DEBUG_MODULE)begin
			always@(posedge iCLOCK or negedge inRESET)begin
				if(!inRESET)begin
					b_reg_read_state <= 1'h0;
					b_reg_read_r_data <= 32'h0;
					b_reg_read_end <= 1'b0;
				end
				else begin
					case(b_reg_read_state)
						L_PARAM_REG_READ_STT_IDLE:
							begin
								b_reg_read_end <= 1'b0;
								if(reg_read_start)begin
									b_reg_read_state <= L_PARAM_REG_READ_STT_READEND;
									case(reg_read_target)
										CORE_DEBUG_TARGET_GR0 : b_reg_read_r_data <= iREG_R_GR0;
										CORE_DEBUG_TARGET_GR1 : b_reg_read_r_data <= iREG_R_GR1;
										CORE_DEBUG_TARGET_GR2 : b_reg_read_r_data <= iREG_R_GR2;
										CORE_DEBUG_TARGET_GR3 : b_reg_read_r_data <= iREG_R_GR3;
										CORE_DEBUG_TARGET_GR4 : b_reg_read_r_data <= iREG_R_GR4;
										CORE_DEBUG_TARGET_GR5 : b_reg_read_r_data <= iREG_R_GR5;
										CORE_DEBUG_TARGET_GR6 : b_reg_read_r_data <= iREG_R_GR6;
										CORE_DEBUG_TARGET_GR7 : b_reg_read_r_data <= iREG_R_GR7;
										CORE_DEBUG_TARGET_GR8 : b_reg_read_r_data <= iREG_R_GR8;
										CORE_DEBUG_TARGET_GR9 : b_reg_read_r_data <= iREG_R_GR9;
										CORE_DEBUG_TARGET_GR10 : b_reg_read_r_data <= iREG_R_GR10;
										CORE_DEBUG_TARGET_GR11 : b_reg_read_r_data <= iREG_R_GR11;
										CORE_DEBUG_TARGET_GR12 : b_reg_read_r_data <= iREG_R_GR12;
										CORE_DEBUG_TARGET_GR13 : b_reg_read_r_data <= iREG_R_GR13;
										CORE_DEBUG_TARGET_GR14 : b_reg_read_r_data <= iREG_R_GR14;
										CORE_DEBUG_TARGET_GR15 : b_reg_read_r_data <= iREG_R_GR15;
										CORE_DEBUG_TARGET_GR16 : b_reg_read_r_data <= iREG_R_GR16;
										CORE_DEBUG_TARGET_GR17 : b_reg_read_r_data <= iREG_R_GR17;
										CORE_DEBUG_TARGET_GR18 : b_reg_read_r_data <= iREG_R_GR18;
										CORE_DEBUG_TARGET_GR19 : b_reg_read_r_data <= iREG_R_GR19;
										CORE_DEBUG_TARGET_GR20 : b_reg_read_r_data <= iREG_R_GR20;
										CORE_DEBUG_TARGET_GR21 : b_reg_read_r_data <= iREG_R_GR21;
										CORE_DEBUG_TARGET_GR22 : b_reg_read_r_data <= iREG_R_GR22;
										CORE_DEBUG_TARGET_GR23 : b_reg_read_r_data <= iREG_R_GR23;
										CORE_DEBUG_TARGET_GR24 : b_reg_read_r_data <= iREG_R_GR24;
										CORE_DEBUG_TARGET_GR25 : b_reg_read_r_data <= iREG_R_GR25;
										CORE_DEBUG_TARGET_GR26 : b_reg_read_r_data <= iREG_R_GR26;
										CORE_DEBUG_TARGET_GR27 : b_reg_read_r_data <= iREG_R_GR27;
										CORE_DEBUG_TARGET_GR28 : b_reg_read_r_data <= iREG_R_GR28;
										CORE_DEBUG_TARGET_GR29 : b_reg_read_r_data <= iREG_R_GR29;
										CORE_DEBUG_TARGET_GR30 : b_reg_read_r_data <= iREG_R_GR30;
										CORE_DEBUG_TARGET_GR31 : b_reg_read_r_data <= iREG_R_GR31;
										CORE_DEBUG_TARGET_FLAGR : b_reg_read_r_data <= iREG_R_FLAGR;
										CORE_DEBUG_TARGET_SPR : b_reg_read_r_data <= iREG_R_SPR;
										CORE_DEBUG_TARGET_PCR : b_reg_read_r_data <= iREG_R_PCR;
										CORE_DEBUG_TARGET_PPCR : b_reg_read_r_data <= iREG_R_PPCR;
										CORE_DEBUG_TARGET_PSR : b_reg_read_r_data <= iREG_R_PSR;
										CORE_DEBUG_TARGET_PPSR : b_reg_read_r_data <= iREG_R_PPSR;
									endcase
								end
							end
						L_PARAM_REG_READ_STT_READEND:
							begin
								b_reg_read_state <= L_PARAM_REG_READ_STT_IDLE;
								b_reg_read_end <= 1'b1;
							end
					endcase
				end
			end
		end
		else begin
			//Disable
			always@(posedge iCLOCK or negedge inRESET)begin
				if(!inRESET)begin
					b_reg_read_state <= 1'h0;
					b_reg_read_r_data <= 32'h0;
					b_reg_read_end <= 1'b0;
				end
				else begin
					b_reg_read_state <= b_reg_read_state;
					b_reg_read_r_data <= b_reg_read_r_data;
					b_reg_read_end <= b_reg_read_end;
				end
			end
		end
	endgenerate
					
	/***************************************************
	//Register Write State
	***************************************************/

	/***************************************************
	//Assign
	***************************************************/
	generate
		//Debug Module Enable
		if(`PROCESSOR_USE_DEBUG_MODULE)begin
			assign oRESP_ERROR = 1'b0;
			//Response
			assign oRESP_VALID = b_main_core_ack | b_reg_read_end;
			assign oRESP_DATA = b_reg_read_r_data;
			assign oDEBUG_CORE_REQ = (main_command == CORE_DEBUG_CMD_GO_CORE || main_command == CORE_DEBUG_CMD_STOP_CORE) && main_command_valid && !this_busy;
			assign oDEBUG_CORE_STOP = (main_command == CORE_DEBUG_CMD_GO_CORE) && main_command_valid && !this_busy;
			assign oDEBUG_CORE_START = (main_command == CORE_DEBUG_CMD_STOP_CORE) && main_command_valid && !this_busy;
		end
		else begin
		//Disable
			assign oRESP_ERROR = 1'b0;
			//Response
			assign oRESP_VALID = 1'b0;
			assign oRESP_DATA = 32'h0;
			assign oDEBUG_CORE_REQ = 1'b0;
			assign oDEBUG_CORE_STOP = 1'b0;
			assign oDEBUG_CORE_START = 1'b0;
		end
	endgenerate
	
	assign oCMD_BUSY = this_busy;
	
endmodule

`default_nettype wire
