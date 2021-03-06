
`include "common.h"
`include "sdi_debugger.h"

`default_nettype none


module core_debug(
		input wire iCLOCK,
		input wire inRESET,
		//CMD
		input wire iCMD_REQ,
		output wire oCMD_BUSY,
		input wire [3:0] iCMD_COMMAND,
		input wire [7:0] iCMD_TARGET,
		input wire [31:0] iCMD_DATA,
		//Response
		output wire oRESP_VALID,
		output wire oRESP_ERROR,
		output wire [31:0] oRESP_DATA,
		//System control
		output wire oDEBUG_CORE_REQ,
		output wire oDEBUG_CORE_STOP,
		output wire oDEBUG_CORE_START,
		input wire iDEBUG_CORE_ACK,
		//Register Read
		input wire [31:0] iREG_R_GR0,
		input wire [31:0] iREG_R_GR1,
		input wire [31:0] iREG_R_GR2,
		input wire [31:0] iREG_R_GR3,
		input wire [31:0] iREG_R_GR4,
		input wire [31:0] iREG_R_GR5,
		input wire [31:0] iREG_R_GR6,
		input wire [31:0] iREG_R_GR7,
		input wire [31:0] iREG_R_GR8,
		input wire [31:0] iREG_R_GR9,
		input wire [31:0] iREG_R_GR10,
		input wire [31:0] iREG_R_GR11,
		input wire [31:0] iREG_R_GR12,
		input wire [31:0] iREG_R_GR13,
		input wire [31:0] iREG_R_GR14,
		input wire [31:0] iREG_R_GR15,
		input wire [31:0] iREG_R_GR16,
		input wire [31:0] iREG_R_GR17,
		input wire [31:0] iREG_R_GR18,
		input wire [31:0] iREG_R_GR19,
		input wire [31:0] iREG_R_GR20,
		input wire [31:0] iREG_R_GR21,
		input wire [31:0] iREG_R_GR22,
		input wire [31:0] iREG_R_GR23,
		input wire [31:0] iREG_R_GR24,
		input wire [31:0] iREG_R_GR25,
		input wire [31:0] iREG_R_GR26,
		input wire [31:0] iREG_R_GR27,
		input wire [31:0] iREG_R_GR28,
		input wire [31:0] iREG_R_GR29,
		input wire [31:0] iREG_R_GR30,
		input wire [31:0] iREG_R_GR31,
		input wire [31:0] iREG_R_CPUIDR,
		input wire [31:0] iREG_R_TIDR,
		input wire [31:0] iREG_R_FLAGR,
		input wire [31:0] iREG_R_PCR,
		input wire [31:0] iREG_R_SPR,
		input wire [31:0] iREG_R_PSR,
		input wire [31:0] iREG_R_IOSAR,
		input wire [31:0] iREG_R_TISR,
		input wire [31:0] iREG_R_IDTR,
		input wire [31:0] iREG_R_FI0R,
		input wire [31:0] iREG_R_FI1R,
		input wire [31:0] iREG_R_FRCLR,
		input wire [31:0] iREG_R_FRCHR,
		input wire [31:0] iREG_R_PTIDR,
		input wire [31:0] iREG_R_PFLAGR,
		input wire [31:0] iREG_R_PPCR,
		input wire [31:0] iREG_R_PPSR,
		input wire [31:0] iREG_R_PPDTR
	);
	
	
	//Command
	localparam CORE_DEBUG_CMD_READ_REG = 4'h0;
	localparam CORE_DEBUG_CMD_WRITE_REG = 4'h1;
	localparam CORE_DEBUG_CMD_GO_CORE = 4'h8;
	localparam CORE_DEBUG_CMD_INTGO_CORE = 4'h9;
	localparam CORE_DEBUG_CMD_SINGLESTEP_CORE = 4'hA;
	localparam CORE_DEBUG_CMD_STOP_CORE = 4'hF;


	localparam L_PARAM_REG_READ_STT_IDLE = 1'h0;
	localparam L_PARAM_REG_READ_STT_READEND = 1'h1;
	

	
	wire this_busy;
	
	/***************************************************
	//Main State
	***************************************************/
	wire main_command_valid = iCMD_REQ && !this_busy;
	wire [3:0] main_command = iCMD_COMMAND;
	wire main_core_ack = iDEBUG_CORE_ACK;
	
	reg b_main_wait;
	reg b_main_core_stop;
	reg b_main_core_ack;


	reg b_reg_read_state;
	reg [31:0] b_reg_read_r_data;
	reg b_reg_read_end;

	wire reg_working = (b_reg_read_state == L_PARAM_REG_READ_STT_READEND);
	wire reg_read_start = b_main_core_stop && !b_main_wait && (iCMD_COMMAND == CORE_DEBUG_CMD_READ_REG) && iCMD_REQ && !this_busy;
	wire reg_read_end = b_reg_read_end;
	wire [7:0] reg_read_target = iCMD_TARGET;

	assign this_busy = b_main_wait || reg_working;
	
	//Debug Module Enable
	`ifdef MIST1032ISA_STANDARD_DEBUGGER
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
	//Disable
	`else
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
	`endif

	
	
	/***************************************************
	//Register Read State
	***************************************************/
	//Debug Module Enable
	`ifdef MIST1032ISA_STANDARD_DEBUGGER
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
									`CORE_DEBUG_TARGET_GR0 : b_reg_read_r_data <= iREG_R_GR0;
									`CORE_DEBUG_TARGET_GR1 : b_reg_read_r_data <= iREG_R_GR1;
									`CORE_DEBUG_TARGET_GR2 : b_reg_read_r_data <= iREG_R_GR2;
									`CORE_DEBUG_TARGET_GR3 : b_reg_read_r_data <= iREG_R_GR3;
									`CORE_DEBUG_TARGET_GR4 : b_reg_read_r_data <= iREG_R_GR4;
									`CORE_DEBUG_TARGET_GR5 : b_reg_read_r_data <= iREG_R_GR5;
									`CORE_DEBUG_TARGET_GR6 : b_reg_read_r_data <= iREG_R_GR6;
									`CORE_DEBUG_TARGET_GR7 : b_reg_read_r_data <= iREG_R_GR7;
									`CORE_DEBUG_TARGET_GR8 : b_reg_read_r_data <= iREG_R_GR8;
									`CORE_DEBUG_TARGET_GR9 : b_reg_read_r_data <= iREG_R_GR9;
									`CORE_DEBUG_TARGET_GR10 : b_reg_read_r_data <= iREG_R_GR10;
									`CORE_DEBUG_TARGET_GR11 : b_reg_read_r_data <= iREG_R_GR11;
									`CORE_DEBUG_TARGET_GR12 : b_reg_read_r_data <= iREG_R_GR12;
									`CORE_DEBUG_TARGET_GR13 : b_reg_read_r_data <= iREG_R_GR13;
									`CORE_DEBUG_TARGET_GR14 : b_reg_read_r_data <= iREG_R_GR14;
									`CORE_DEBUG_TARGET_GR15 : b_reg_read_r_data <= iREG_R_GR15;
									`CORE_DEBUG_TARGET_GR16 : b_reg_read_r_data <= iREG_R_GR16;
									`CORE_DEBUG_TARGET_GR17 : b_reg_read_r_data <= iREG_R_GR17;
									`CORE_DEBUG_TARGET_GR18 : b_reg_read_r_data <= iREG_R_GR18;
									`CORE_DEBUG_TARGET_GR19 : b_reg_read_r_data <= iREG_R_GR19;
									`CORE_DEBUG_TARGET_GR20 : b_reg_read_r_data <= iREG_R_GR20;
									`CORE_DEBUG_TARGET_GR21 : b_reg_read_r_data <= iREG_R_GR21;
									`CORE_DEBUG_TARGET_GR22 : b_reg_read_r_data <= iREG_R_GR22;
									`CORE_DEBUG_TARGET_GR23 : b_reg_read_r_data <= iREG_R_GR23;
									`CORE_DEBUG_TARGET_GR24 : b_reg_read_r_data <= iREG_R_GR24;
									`CORE_DEBUG_TARGET_GR25 : b_reg_read_r_data <= iREG_R_GR25;
									`CORE_DEBUG_TARGET_GR26 : b_reg_read_r_data <= iREG_R_GR26;
									`CORE_DEBUG_TARGET_GR27 : b_reg_read_r_data <= iREG_R_GR27;
									`CORE_DEBUG_TARGET_GR28 : b_reg_read_r_data <= iREG_R_GR28;
									`CORE_DEBUG_TARGET_GR29 : b_reg_read_r_data <= iREG_R_GR29;
									`CORE_DEBUG_TARGET_GR30 : b_reg_read_r_data <= iREG_R_GR30;
									`CORE_DEBUG_TARGET_GR31 : b_reg_read_r_data <= iREG_R_GR31;
									`CORE_DEBUG_TARGET_CPUIDR : b_reg_read_r_data <= iREG_R_CPUIDR;
									`CORE_DEBUG_TARGET_TIDR : b_reg_read_r_data <= iREG_R_TIDR;
									`CORE_DEBUG_TARGET_FLAGR : b_reg_read_r_data <= iREG_R_FLAGR;
									`CORE_DEBUG_TARGET_PCR : b_reg_read_r_data <= iREG_R_PCR;
									`CORE_DEBUG_TARGET_SPR : b_reg_read_r_data <= iREG_R_SPR;
									`CORE_DEBUG_TARGET_PSR : b_reg_read_r_data <= iREG_R_PSR;
									`CORE_DEBUG_TARGET_IOSAR : b_reg_read_r_data <= iREG_R_IOSAR;
									`CORE_DEBUG_TARGET_TISR : b_reg_read_r_data <= iREG_R_TISR;
									`CORE_DEBUG_TARGET_IDTR : b_reg_read_r_data <= iREG_R_IDTR;
									`CORE_DEBUG_TARGET_FI0R : b_reg_read_r_data <= iREG_R_FI0R;
									`CORE_DEBUG_TARGET_FI1R : b_reg_read_r_data <= iREG_R_FI1R;
									`CORE_DEBUG_TARGET_FRCLR : b_reg_read_r_data <= iREG_R_FRCLR;
									`CORE_DEBUG_TARGET_FRCHR : b_reg_read_r_data <= iREG_R_FRCHR;
									`CORE_DEBUG_TARGET_PTIDR : b_reg_read_r_data <= iREG_R_PTIDR;
									`CORE_DEBUG_TARGET_PFLAGR : b_reg_read_r_data <= iREG_R_PFLAGR;
									`CORE_DEBUG_TARGET_PPCR : b_reg_read_r_data <= iREG_R_PPCR;
									`CORE_DEBUG_TARGET_PPSR : b_reg_read_r_data <= iREG_R_PPSR;
									`CORE_DEBUG_TARGET_PPDTR : b_reg_read_r_data <= iREG_R_PPDTR;
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
	`else
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
	`endif
					
	/***************************************************
	//Register Write State
	***************************************************/

	/***************************************************
	//Assign
	***************************************************/

	//Debug Module Enable
	`ifdef MIST1032ISA_STANDARD_DEBUGGER
		assign oRESP_ERROR = 1'b0;
		//Response
		assign oRESP_VALID = b_main_core_ack | b_reg_read_end;
		assign oRESP_DATA = b_reg_read_r_data;
		assign oDEBUG_CORE_REQ = (main_command == CORE_DEBUG_CMD_GO_CORE || main_command == CORE_DEBUG_CMD_STOP_CORE) && main_command_valid && !this_busy;
		assign oDEBUG_CORE_STOP = (main_command == CORE_DEBUG_CMD_GO_CORE) && main_command_valid && !this_busy;
		assign oDEBUG_CORE_START = (main_command == CORE_DEBUG_CMD_STOP_CORE) && main_command_valid && !this_busy;
	`else
	//Disable
		assign oRESP_ERROR = 1'b0;
		//Response
		assign oRESP_VALID = 1'b0;
		assign oRESP_DATA = 32'h0;
		assign oDEBUG_CORE_REQ = 1'b0;
		assign oDEBUG_CORE_STOP = 1'b0;
		assign oDEBUG_CORE_START = 1'b0;
	`endif
	
	assign oCMD_BUSY = this_busy;
	
endmodule

`default_nettype wire
