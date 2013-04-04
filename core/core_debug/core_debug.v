`include "processor.h"
`default_nettype none

module core_debug(
		input iCLOCK,
		input inRESET,
		//CMD
		input iCMD_REQ,
		output oCMD_BUSY,
		input [3:0] iCMD_COMMAND,
		input [7:0] iCMD_TARGET,
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
		input [31:0] iREG_R_CPUIDR,
		input [31:0] iREG_R_TIDR,
		input [31:0] iREG_R_FLAGR,
		input [31:0] iREG_R_PCR,
		input [31:0] iREG_R_SPR,
		input [31:0] iREG_R_PSR,
		input [31:0] iREG_R_IOSAR,
		input [31:0] iREG_R_TISR,
		input [31:0] iREG_R_IDTR,
		input [31:0] iREG_R_FI0R,
		input [31:0] iREG_R_FI1R,
		input [31:0] iREG_R_FRCLR,
		input [31:0] iREG_R_FRCHR,
		input [31:0] iREG_R_PTIDR,
		input [31:0] iREG_R_PFLAGR,
		input [31:0] iREG_R_PPCR,
		input [31:0] iREG_R_PPSR,
		input [31:0] iREG_R_PPDTR
	);
	
	
	//Command
	localparam CORE_DEBUG_CMD_READ_REG = 4'h0;
	localparam CORE_DEBUG_CMD_WRITE_REG = 4'h1;
	localparam CORE_DEBUG_CMD_GO_CORE = 4'h8;
	localparam CORE_DEBUG_CMD_INTGO_CORE = 4'h9;
	localparam CORE_DEBUG_CMD_SINGLESTEP_CORE = 4'hA;
	localparam CORE_DEBUG_CMD_STOP_CORE = 4'hF;
	
	//Register Target
	localparam CORE_DEBUG_TARGET_GR0 = 8'd0;
	localparam CORE_DEBUG_TARGET_GR1 = 8'd1;
	localparam CORE_DEBUG_TARGET_GR2 = 8'd2;
	localparam CORE_DEBUG_TARGET_GR3 = 8'd3;
	localparam CORE_DEBUG_TARGET_GR4 = 8'd4;
	localparam CORE_DEBUG_TARGET_GR5 = 8'd5;
	localparam CORE_DEBUG_TARGET_GR6 = 8'd6;
	localparam CORE_DEBUG_TARGET_GR7 = 8'd7;
	localparam CORE_DEBUG_TARGET_GR8 = 8'd8;
	localparam CORE_DEBUG_TARGET_GR9 = 8'd9;
	localparam CORE_DEBUG_TARGET_GR10 = 8'd10;
	localparam CORE_DEBUG_TARGET_GR11 = 8'd11;
	localparam CORE_DEBUG_TARGET_GR12 = 8'd12;
	localparam CORE_DEBUG_TARGET_GR13 = 8'd13;
	localparam CORE_DEBUG_TARGET_GR14 = 8'd14;
	localparam CORE_DEBUG_TARGET_GR15 = 8'd15;
	localparam CORE_DEBUG_TARGET_GR16 = 8'd16;
	localparam CORE_DEBUG_TARGET_GR17 = 8'd17;
	localparam CORE_DEBUG_TARGET_GR18 = 8'd18;
	localparam CORE_DEBUG_TARGET_GR19 = 8'd19;
	localparam CORE_DEBUG_TARGET_GR20 = 8'd20;
	localparam CORE_DEBUG_TARGET_GR21 = 8'd21;
	localparam CORE_DEBUG_TARGET_GR22 = 8'd22;
	localparam CORE_DEBUG_TARGET_GR23 = 8'd23;
	localparam CORE_DEBUG_TARGET_GR24 = 8'd24;
	localparam CORE_DEBUG_TARGET_GR25 = 8'd25;
	localparam CORE_DEBUG_TARGET_GR26 = 8'd26;
	localparam CORE_DEBUG_TARGET_GR27 = 8'd27;
	localparam CORE_DEBUG_TARGET_GR28 = 8'd28;
	localparam CORE_DEBUG_TARGET_GR29 = 8'd29;
	localparam CORE_DEBUG_TARGET_GR30 = 8'd30;
	localparam CORE_DEBUG_TARGET_GR31 = 8'd31;
	localparam CORE_DEBUG_TARGET_CPUIDR = 8'd64;
	localparam CORE_DEBUG_TARGET_TIDR = 8'd65;
	localparam CORE_DEBUG_TARGET_FLAGR = 8'd66;
	localparam CORE_DEBUG_TARGET_PCR = 8'd67;
	localparam CORE_DEBUG_TARGET_SPR = 8'd68;
	localparam CORE_DEBUG_TARGET_PSR = 8'd69;
	localparam CORE_DEBUG_TARGET_IOSAR = 8'd70;
	localparam CORE_DEBUG_TARGET_PDTR = 8'd71;
	localparam CORE_DEBUG_TARGET_KPDTR = 8'd72;
	localparam CORE_DEBUG_TARGET_TISR = 8'd73;
	localparam CORE_DEBUG_TARGET_IDTR = 8'd74;
	localparam CORE_DEBUG_TARGET_FI0R = 8'd75;
	localparam CORE_DEBUG_TARGET_FI1R = 8'd76;
	localparam CORE_DEBUG_TARGET_FRCLR = 8'd77;
	localparam CORE_DEBUG_TARGET_FRCHR = 8'd78;
	localparam CORE_DEBUG_TARGET_PTIDR = 8'd128;
	localparam CORE_DEBUG_TARGET_PFLAGR = 8'd129;
	localparam CORE_DEBUG_TARGET_PPCR = 8'd130;
	localparam CORE_DEBUG_TARGET_PPSR = 8'd131;
	localparam CORE_DEBUG_TARGET_PPDTR = 8'd132;

	
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
	wire [7:0] reg_read_target = iCMD_TARGET;
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
										CORE_DEBUG_TARGET_CPUIDR : b_reg_read_r_data <= iREG_R_CPUIDR;
										CORE_DEBUG_TARGET_TIDR : b_reg_read_r_data <= iREG_R_TIDR;
										CORE_DEBUG_TARGET_FLAGR : b_reg_read_r_data <= iREG_R_FLAGR;
										CORE_DEBUG_TARGET_PCR : b_reg_read_r_data <= iREG_R_PCR;
										CORE_DEBUG_TARGET_SPR : b_reg_read_r_data <= iREG_R_SPR;
										CORE_DEBUG_TARGET_PSR : b_reg_read_r_data <= iREG_R_PSR;
										CORE_DEBUG_TARGET_IOSAR : b_reg_read_r_data <= iREG_R_IOSAR;
										CORE_DEBUG_TARGET_TISR : b_reg_read_r_data <= iREG_R_TISR;
										CORE_DEBUG_TARGET_IDTR : b_reg_read_r_data <= iREG_R_IDTR;
										CORE_DEBUG_TARGET_FI0R : b_reg_read_r_data <= iREG_R_FI0R;
										CORE_DEBUG_TARGET_FI1R : b_reg_read_r_data <= iREG_R_FI1R;
										CORE_DEBUG_TARGET_FRCLR : b_reg_read_r_data <= iREG_R_FRCLR;
										CORE_DEBUG_TARGET_FRCHR : b_reg_read_r_data <= iREG_R_FRCHR;
										CORE_DEBUG_TARGET_PTIDR : b_reg_read_r_data <= iREG_R_PTIDR;
										CORE_DEBUG_TARGET_PFLAGR : b_reg_read_r_data <= iREG_R_PFLAGR;
										CORE_DEBUG_TARGET_PPCR : b_reg_read_r_data <= iREG_R_PPCR;
										CORE_DEBUG_TARGET_PPSR : b_reg_read_r_data <= iREG_R_PPSR;
										CORE_DEBUG_TARGET_PPDTR : b_reg_read_r_data <= iREG_R_PPDTR;
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
