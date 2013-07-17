
`default_nettype none
module processor_debugger(
		//Clock 
		input wire iCLOCK,
		input wire inRESET,
		//To Core
		output wire oDEBUG_CMD_REQ,
		input wire iDEBUG_CMD_BUSY,
		output wire [3:0] oDEBUG_CMD_COMMAND,
		output wire [7:0] oDEBUG_CMD_TARGET,
		output wire [31:0] oDEBUG_CMD_DATA,
		input wire iDEBUG_CMD_VALID,
		input wire iDEBUG_CMD_ERROR,
		input wire [31:0] iDEBUG_CMD_DATA,
		//To Uart
		input wire iDEBUG_UART_RXD,
		output wire oDEBUG_UART_TXD,
		input wire iDEBUG_PARA_REQ,
		output wire oDEBUG_PARA_BUSY,
		input wire [7:0] iDEBUG_PARA_CMD,
		input wire [31:0] iDEBUG_PARA_DATA,
		output wire oDEBUG_PARA_VALID,
		input wire iDEBUG_PARA_BUSY,
		output wire oDEBUG_PARA_ERROR,
		output wire [31:0] oDEBUG_PARA_DATA
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
	
	
	//Uart Debuger Module
	

	

	/****************************************************************
	Interface Select
	****************************************************************/
	wire debug_
	
	

	input wire iDEBUG_PARA_REQ,
	output wire oDEBUG_PARA_BUSY,
	input wire [7:0] iDEBUG_PARA_CMD,
	input wire [31:0] iDEBUG_PARA_DATA,
	output wire oDEBUG_PARA_VALID,
	input wire iDEBUG_PARA_BUSY,
	output wire oDEBUG_PARA_ERROR,
	output wire [31:0] oDEBUG_PARA_DATA

	
	/****************************************************************
	Uart Command Check
	****************************************************************/
	localparam L_PARAM_CMDCODE_ID = 8'h49;
	localparam L_PARAM_CMDCODE_AC = 8'h41;
	localparam L_PARAM_CMDCODE_NP = 8'h4e;
	localparam L_PARAM_CMDCODE_RR = 8'h52;
	localparam L_PARAM_CMDCODE_RW = 8'h57;
	localparam L_PARAM_CMDCODE_SE = 8'h53;
	localparam L_PARAM_CMDCODE_BE = 8'h42;
	localparam L_PARAM_CMDCODE_SB = 8'h50;
	
	
	
	reg [3:0] b_cmd_state;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			if(!inRESET)begin
				b_cmd_state <= L_PARAM_MAIN_STT_IDLE;
			end
			else begin
				case(b_cmd_state)
					L_PARAM_MAIN_STT_IDLE:
						begin
							//
						end
					L_PARAM_MAIN_STT_ACTIVE:
						begin
							//
						end
					L_PARAM_MAIN_STT_NOP:
						begin
							//
						end
					L_PARAM_MAIN_STT_REGISTER_READ:
						begin
							//
						end
					L_PARAM_MAIN_STT_REGISTER_WRITE:
						begin
							//
						end
					L_PARAM_MAIN_STT_STEP_EXECUTE:
						begin
							//
						end
					L_PARAM_MAIN_STT_BREAK_EXECUTE:
						begin
							//
						end
					L_PARAM_MAIN_STT_SET_BREAK_POINT:
						begin
							//
						end
					L_PARAM_MAIN_STT_ERROR:
						begin
							//
						end
					default:
						begin
							//
						end
				endcase
			end
		end
	end //CMD State

	
	localparam L_PARAM_MAIN_STT_IDLE = 4'h0;
	localparam L_PARAM_MAIN_STT_ACTIVE = 4'h1;
	localparam L_PARAM_MAIN_STT_NOP = 4'h2;
	localparam L_PARAM_MAIN_STT_REGISTER_READ = 4'h3;
	localparam L_PARAM_MAIN_STT_REGISTER_WRITE = 4'h4;
	localparam L_PARAM_MAIN_STT_STEP_EXECUTE = 4'h5;
	localparam L_PARAM_MAIN_STT_BREAK_EXECUTE = 4'h6;
	localparam L_PARAM_MAIN_STT_SET_BREAK_POINT = 4'h7;
	localparam L_PARAM_MAIN_STT_ERROR = 4'h8;

	
	
	processor_debugger_uart_transmit_format UART_FORMAT(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iTXD_REQ(uartformat_txd_req),
		.oTXD_BUSY(uartformat_busy),
		.iTXD_START_EN(b_main_counter == 6'h0),
		.iTXD_SPLIT_EN(b_main_counter != 6'd37),
		.iTXD_STOP_EN(b_main_counter == 6'd37),
		.iTXD_DATA(uartformat_txd_data),
		//Uart 
		.oUART_REQ(uartmod_txd_req),
		.iUART_BUSY(uartmod_txd_busy),
		.oUART_DATA(uartmod_txd_data)
	);
	
		
	
	localparam L_PARAM_MAIN_STT_IDLE = 4'h0;
	localparam L_PARAM_MAIN_STT_ACTIVE = 4'h1;
	localparam L_PARAM_MAIN_STT_ALL_REGISTER_READ = 4'h2;
	localparam L_PARAM_MAIN_STT_REGISTER_READ = 4'h3;
	localparam L_PARAM_MAIN_STT_REGISTER_WRITE = 4'h4;
	localparam L_PARAM_MAIN_STT_STEP_EXECUTE = 4'h5;
	localparam L_PARAM_MAIN_STT_BREAK_EXECUTE = 4'h6;
	localparam L_PARAM_MAIN_STT_SET_BREAK_POINT = 4'h7;
	localparam L_PARAM_MAIN_STT_ERROR = 4'h8;
	
	reg [3:0] b_main_state;
	reg [2:0] b_main_next_state;
	reg b_main_wait;
	reg [5:0] b_main_counter;
	reg [31:0] b_main_register_data[0:36];
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_state <= L_PARAM_MAIN_STT_IDLE;
			b_main_next_state <= 3'h0;
			b_main_wait <= 1'b0;
			b_main_counter <= 6'h0;
		end
		else if(b_main_wait)begin

		end
		else begin
			case(b_main_state)
				L_PARAM_MAIN_STT_IDLE:
					begin
						b_main_counter <= 6'h0;
						if(b_uart_cmd_request)begin
							b_main_state <= b_uart_cmd_request_state;
						end
					end
				L_PARAM_MAIN_STT_ACTIVE:
					begin
						b_main_counter <= 6'h0;
						if(b_uart_cmd_request)begin
							b_main_state <= b_uart_cmd_request_state;
						end
					end
				L_PARAM_MAIN_STT_ALL_REGISTER_READ:
					begin
						//
					end
				L_PARAM_MAIN_STT_REGISTER_READ:
					begin
						//
					endcase
				L_PARAM_MAIN_STT_REGISTER_WRITE:
					begin
						//
					end
				L_PARAM_MAIN_STT_STEP_EXECUTE:
					begin
						//
					end
				L_PARAM_MAIN_STT_BREAK_EXECUTE:
					begin
						//
					end
				L_PARAM_MAIN_STT_SET_BREAK_POINT:
					begin
						//
					end
			endcase
		end
	end //always main state
	
	//Assign
	reg [3:0] debug_command;
	always @* begin
		case(b_main_state)
			L_PARAM_MAIN_STT_STOP_CORE : debug_command = CORE_DEBUG_CMD_STOP_CORE;
			L_PARAM_MAIN_STT_GET_REGISTER_ALL : debug_command = CORE_DEBUG_CMD_READ_REG;
			L_PARAM_MAIN_STT_START_CORE : debug_command = CORE_DEBUG_CMD_GO_CORE;
			default : debug_command = 4'h0;
		endcase
	end
	
	assign uartformat_txd_req = (b_main_state == L_PARAM_MAIN_STT_SEND_REGISTER_ALL)? !b_main_wait : 1'b0;
	assign uartformat_txd_data = b_main_register_data[b_main_counter];
	
	assign oDEBUG_CMD_REQ = (b_main_state == L_PARAM_MAIN_STT_STOP_CORE || b_main_state == L_PARAM_MAIN_STT_GET_REGISTER_ALL || b_main_state == L_PARAM_MAIN_STT_START_CORE)? !b_main_wait : 1'b0;
	assign oDEBUG_CMD_COMMAND = debug_command;
	assign oDEBUG_CMD_TARGET = //b_main_counter;
	
	
	
endmodule


`default_nettype wire

