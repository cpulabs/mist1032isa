
`default_nettype none
module processor_debugger(
		//Clock 
		input iCLOCK,
		input inRESET,
		//To Core
		output oDEBUG_CMD_REQ,
		input iDEBUG_CMD_BUSY,
		output [3:0] oDEBUG_CMD_COMMAND,
		output [11:0] oDEBUG_CMD_TARGET,
		output [31:0] oDEBUG_CMD_DATA,
		input iDEBUG_CMD_VALID,
		input iDEBUG_CMD_ERROR,
		input [31:0] iDEBUG_CMD_DATA,
		//To Uart
		input iUART_RXD,
		output oUART_TXD
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
	
	
	
	//Uart Debuger Module
	
	//Uart Module
	wire uartmod_txd_req;
	wire uartmod_txd_busy;
	wire [7:0] uartmod_txd_data;
	wire uartmod_rxd_valid;
	//Uart Format Module
	wire uartformat_txd_req;
	wire uartformat_busy;
	wire [31:0] uartformat_txd_data;
	
	
	//Clock / Baudrate = parameter
	processor_debugger_uart #(13'h1458) UART_IF(		//9600bps
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Request
		.iTX_REQ(uartmod_txd_req),
		.oTX_BUSY(uartmod_txd_busy),
		.iTX_DATA(uartmod_txd_data),	
		.oRX_VALID(uartmod_rxd_valid),
		.oRX_DATA(),
		//UART
		.oUART_TXD(oUART_TXD),
		.iUART_RXD(iUART_RXD)
	);	
	
	
	
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
	
	
	localparam L_PARAM_MAIN_STT_IDLE = 3'h0;
	localparam L_PARAM_MAIN_STT_STOP_CORE = 3'h1;
	localparam L_PARAM_MAIN_STT_GET_REGISTER_ALL = 3'h2;
	localparam L_PARAM_MAIN_STT_START_CORE = 3'h3;
	localparam L_PARAM_MAIN_STT_SEND_REGISTER_ALL = 3'h4;
	
	reg [2:0] b_main_state;
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
			case(b_main_state)
				L_PARAM_MAIN_STT_STOP_CORE:
					begin
						if(iDEBUG_CMD_VALID)begin
							b_main_wait <= 1'b0;
							b_main_state <= b_main_next_state;
						end
					end
				L_PARAM_MAIN_STT_GET_REGISTER_ALL:
					begin
						if(iDEBUG_CMD_VALID)begin
							b_main_wait <= 1'b0;
							b_main_state <= b_main_next_state;
							b_main_register_data[b_main_counter-6'h1] <= iDEBUG_CMD_DATA;
						end
					end
				L_PARAM_MAIN_STT_START_CORE:
					begin
						if(iDEBUG_CMD_VALID)begin
							b_main_wait <= 1'b0;
							b_main_state <= b_main_next_state;
						end
					end
				L_PARAM_MAIN_STT_SEND_REGISTER_ALL:
					begin
						if(!uartformat_busy)begin
							b_main_wait <= 1'b0;
							b_main_state <= b_main_next_state;
						end
					end
				default:
					begin
						b_main_wait <= 1'b0;
						b_main_state <= L_PARAM_MAIN_STT_IDLE;
					end
			endcase
		end
		else begin
			case(b_main_state)
				L_PARAM_MAIN_STT_IDLE:
					begin
						b_main_counter <= 6'h0;
						if(uartmod_rxd_valid)begin
							b_main_state <= L_PARAM_MAIN_STT_STOP_CORE;
						end
					end
				L_PARAM_MAIN_STT_STOP_CORE:
					begin
						b_main_wait <= 1'b1;
						b_main_next_state <= L_PARAM_MAIN_STT_GET_REGISTER_ALL;
					end
				L_PARAM_MAIN_STT_GET_REGISTER_ALL:
					begin
						if(b_main_counter < 6'd37)begin
							b_main_wait <= 1'b1;
							b_main_counter <= b_main_counter + 6'h1;
							b_main_next_state <= L_PARAM_MAIN_STT_GET_REGISTER_ALL;
						end
						else begin
							b_main_counter <= 6'h0;
							b_main_wait <= 1'b1;
							b_main_next_state <= L_PARAM_MAIN_STT_START_CORE;
						end
					end
				L_PARAM_MAIN_STT_START_CORE:
					begin
						b_main_wait <= 1'b1;
						b_main_next_state <= L_PARAM_MAIN_STT_SEND_REGISTER_ALL;
					end
				L_PARAM_MAIN_STT_SEND_REGISTER_ALL:
					begin
						b_main_counter <= b_main_counter + 6'h1;
						if(b_main_counter < 6'd37)begin
							b_main_wait <= 1'b1;
							b_main_next_state <= L_PARAM_MAIN_STT_SEND_REGISTER_ALL;
						end
						else begin
							b_main_wait <= 1'b1;
							b_main_next_state <= L_PARAM_MAIN_STT_IDLE;
						end
					end
				default:
					begin
						b_main_state <= L_PARAM_MAIN_STT_IDLE;
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
	assign oDEBUG_CMD_TARGET = b_main_counter;
	
	
	
endmodule


`default_nettype wire

