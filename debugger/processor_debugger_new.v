
`default_nettype none
module processor_debugger(
		//Clock 
		input iCLOCK,
		input inRESET,
		//To Core
		output oDEBUG_CMD_REQ,
		input iDEBUG_CMD_BUSY,
		output [3:0] oDEBUG_CMD_COMMAND,
		output [7:0] oDEBUG_CMD_TARGET,
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
	
	//Uart Module
	wire uartmod_txd_req;
	wire uartmod_txd_busy;
	wire [7:0] uartmod_txd_data;
	wire uartmod2rdqueue_rxd_valid;
	wire [7:0] uartmod2rdqueue_rxd_data;
	//ED Queue
	wire [7:0] rdqueue2commandcheck_data;
	wire rdqueue2commandcheck_empty;
	//Uart Format Module
	wire uartformat_txd_req;
	wire uartformat_busy;
	wire [31:0] uartformat_txd_data;
	
	/****************************************************************
	Uart
	****************************************************************/
	//Uart Module
	//Baudrate (Clock / Baudrate = parameter) 9600bps = 13'h1458, 57600bps = 13'h364
	processor_debugger_uart #(13'h364) UART_IF(	
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Request
		.iTX_REQ(uartmod_txd_req),
		.oTX_BUSY(uartmod_txd_busy),
		.iTX_DATA(uartmod_txd_data),	
		.oRX_VALID(uartmod2rdqueue_rxd_valid),
		.oRX_DATA(uartmod2rdqueue_rxd_data),
		//UART
		.oUART_TXD(oUART_TXD),
		.iUART_RXD(iUART_RXD)
	);	
	
	//Rxd Queue
	mist1032isa_sync_fifo #(8, 16, 4) INST_LOOPBUFFER(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iREMOVE(1'b0), 
		.oCOUNT(), 	
		.iWR_EN(uartmod2rdqueue_rxd_valid), 
		.iWR_DATA(uartmod2rdqueue_rxd_data), 
		.oWR_FULL(),
		.iRD_EN(!b_uart_cmd_request && !rdqueue2commandcheck_empty), 
		.oRD_DATA(rdqueue2commandcheck_data), 
		.oRD_EMPTY(rdqueue2commandcheck_empty)
	);
	
	
	/****************************************************************
	Uart Command Check
	****************************************************************/
	parameter L_PARAM_UART_CMDCODE_ID = 16'h4944;
	parameter L_PARAM_UART_CMDCODE_AC = 16'h4143;
	parameter L_PARAM_UART_CMDCODE_AR = 16'h4152;
	parameter L_PARAM_UART_CMDCODE_RR = 16'h5252;
	parameter L_PARAM_UART_CMDCODE_RW = 16'h5257;
	parameter L_PARAM_UART_CMDCODE_SE = 16'h5345;
	parameter L_PARAM_UART_CMDCODE_BE = 16'h4245;
	parameter L_PARAM_UART_CMDCODE_SB = 16'h5342;
	
	reg [3:0] b_uart_cmd_state;
	reg [15:0] b_uart_cmd_cmd;
	reg [2:0] b_uart_cmd_rd_counter;
	reg [7:0] b_uart_cmd_select_reg;
	reg [31:0] b_uart_cmd_data;
	reg b_uart_cmd_request;
	reg [3:0] b_uart_cmd_request_state;
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_uart_cmd_state <= 4'h0;
			b_uart_cmd_cmd <= 16'h0;
			b_uart_cmd_rd_counter <= 3'h0;
			b_uart_cmd_select_reg <= 8'h0;
			b_uart_cmd_data <= 32'h0;
			b_uart_cmd_request <= 1'b0;
			b_uart_cmd_request_state <= L_PARAM_MAIN_STT_IDLE;
		end
		else begin
			if(b_uart_cmd_request)begin
				b_uart_cmd_request <= 1'b0;
				b_uart_cmd_rd_counter <= 3'h0;
			end
			else begin
				if(!rdqueue2commandcheck_empty)begin
					b_uart_cmd_cmd <= {b_uart_cmd_cmd[7:0], rdqueue2commandcheck_data};
					b_uart_cmd_rd_counter <= b_uart_cmd_rd_counter + 3'b1
					if(b_uart_cmd_rd_counter == 3'h1)begin
						//Check Command
						b_uart_cmd_request <= 1'b1;
						case(b_uart_cmd_cmd)
							L_PARAM_UART_CMDCODE_ID:
								begin
									if(b_main_state == L_PARAM_MAIN_STT_IDLE || b_main_state == L_PARAM_MAIN_STT_ACTIVE)begin
										b_uart_cmd_request_state <= L_PARAM_MAIN_STT_IDLE;
									end
									else begin
										b_uart_cmd_request_state <= L_PARAM_MAIN_STT_ERROR;
									end
								end
							L_PARAM_UART_CMDCODE_AC:
								begin
									if(b_main_state == L_PARAM_MAIN_STT_IDLE)begin
										b_uart_cmd_request_state <= L_PARAM_MAIN_STT_ACTIVE;
									end
									else begin
										b_uart_cmd_request_state <= L_PARAM_MAIN_STT_ERROR;
									end
								end
							L_PARAM_UART_CMDCODE_AR:
								begin
									if(b_main_state == L_PARAM_MAIN_STT_ACTIVE)begin
										b_uart_cmd_request_state <= L_PARAM_MAIN_STT_ALL_REGISTER_READ;
									end
									else begin
										b_uart_cmd_request_state <= L_PARAM_MAIN_STT_ERROR;
									end
								end
							L_PARAM_UART_CMDCODE_RR:
								begin
									b_uart_cmd_request_state <= L_PARAM_MAIN_STT_ALL_REGISTER_READ;
								end
							L_PARAM_UART_CMDCODE_RW:
								begin
									b_uart_cmd_request_state <= L_PARAM_MAIN_STT_REGISTER_READ;
								end
							L_PARAM_UART_CMDCODE_SE:
								begin
									if(b_main_state == L_PARAM_MAIN_STT_ACTIVE)begin
										b_uart_cmd_request_state <= L_PARAM_MAIN_STT_STEP_EXECUTE;
									end
									else begin
										b_uart_cmd_request_state <= L_PARAM_MAIN_STT_ERROR;
									end
								end
							L_PARAM_UART_CMDCODE_BE:
								begin
									if(b_main_state == L_PARAM_MAIN_STT_ACTIVE)begin
										b_uart_cmd_request_state <= L_PARAM_MAIN_STT_BREAK_EXECUTE;
									end
									else begin
										b_uart_cmd_request_state <= L_PARAM_MAIN_STT_ERROR;
									end
								end
							L_PARAM_UART_CMDCODE_SB:
								begin
									b_uart_cmd_request_state <= L_PARAM_MAIN_STT_BREAK_EXECUTE;
								end
							default:
								begin
									b_uart_cmd_request_state <= L_PARAM_MAIN_STT_ERROR;
								end
						endcase
					end
				end
			end
		end
	end	localparam L_PARAM_MAIN_STT_IDLE = 4'h0;
	localparam L_PARAM_MAIN_STT_ACTIVE = 4'h1;
	localparam L_PARAM_MAIN_STT_ALL_REGISTER_READ = 4'h2;
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

