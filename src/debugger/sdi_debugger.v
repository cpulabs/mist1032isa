
`default_nettype none
module sdi_debugger(
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

	//Command(ToCore Debugger Unit)
	localparam CORE_DEBUG_CMD_READ_REG = 4'h0;
	localparam CORE_DEBUG_CMD_WRITE_REG = 4'h1;
	localparam CORE_DEBUG_CMD_GO_CORE = 4'h8;
	localparam CORE_DEBUG_CMD_INTGO_CORE = 4'h9;
	localparam CORE_DEBUG_CMD_SINGLESTEP_CORE = 4'hA;
	localparam CORE_DEBUG_CMD_STOP_CORE = 4'hF;
	
	//Target Register
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
	
	//Debugger Native Command
	localparam L_PARAM_CMDCODE_ID = 8'h49;
	localparam L_PARAM_CMDCODE_AC = 8'h41;
	localparam L_PARAM_CMDCODE_NP = 8'h4e;
	localparam L_PARAM_CMDCODE_RR = 8'h52;
	localparam L_PARAM_CMDCODE_RW = 8'h57;
	localparam L_PARAM_CMDCODE_SE = 8'h53;
	localparam L_PARAM_CMDCODE_BE = 8'h42;
	localparam L_PARAM_CMDCODE_SB = 8'h50;

	localparam L_PARAM_MAIN_STT_IDLE = 4'h0;
	localparam L_PARAM_MAIN_STT_ACTIVE = 4'h1;
	localparam L_PARAM_MAIN_STT_NOP = 4'h2;
	localparam L_PARAM_MAIN_STT_REGISTER_READ = 4'h3;
	localparam L_PARAM_MAIN_STT_REGISTER_WRITE = 4'h4;
	localparam L_PARAM_MAIN_STT_STEP_EXECUTE = 4'h5;
	localparam L_PARAM_MAIN_STT_BREAK_EXECUTE = 4'h6;
	localparam L_PARAM_MAIN_STT_SET_BREAK_POINT = 4'h7;
	localparam L_PARAM_MAIN_STT_ERROR = 4'h8;

	localparam L_PARAM_CORE_ACK_STT_IDLE = 2'h0;
	localparam L_PARAM_CORE_ACK_STT_WAIT = 2'h1;
	localparam L_PARAM_CORE_ACK_STT_IF_ACK = 2'h2;
	
	
	//Interface
	wire if2ctrl_req;
	wire ctrl2if_busy;
	wire [7:0] if2ctrl_cmd;
	wire [31:0] if2ctrl_data;
	wire ctrl2if_valid;
	wire if2ctrl_busy;
	wire ctrl2if_error;
	wire [31:0] ctrl2if_data;
	
	reg [31:0] b_if_req_data;
	reg [3:0] b_cmd_state;
	reg [1:0] b_ack_state;
	reg core_buff_error;
	reg [31:0] core_buff_data;
	reg core_req_req;
	reg [3:0] core_req_cmd;
	reg [31:0] core_req_data;

	wire interface_req_condition = if2ctrl_req && !ctrl2if_busy && !iDEBUG_CMD_BUSY;
	wire ack_state_start_condition = (b_cmd_state != L_PARAM_MAIN_STT_IDLE) && (b_cmd_state != L_PARAM_MAIN_STT_ACTIVE) && (b_cmd_state != L_PARAM_MAIN_STT_NOP) && (b_cmd_state != L_PARAM_MAIN_STT_ERROR);
	
	

	/****************************************************************
	Interface Select
	****************************************************************/
	sdi_interface_control INTERFACE_CONTROL(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Interface Select
		.iIF_SELECT(1'b1),				//(0)UART | (1)PARALLEL
		//UART
		.iDEBUG_UART_RXD(iDEBUG_UART_RXD),
		.oDEBUG_UART_TXD(oDEBUG_UART_TXD),
		//Parallel
		.iDEBUG_PARA_REQ(iDEBUG_PARA_REQ),
		.oDEBUG_PARA_BUSY(oDEBUG_PARA_BUSY),
		.iDEBUG_PARA_CMD(iDEBUG_PARA_CMD),
		.iDEBUG_PARA_DATA(iDEBUG_PARA_DATA),
		.oDEBUG_PARA_VALID(oDEBUG_PARA_VALID),
		.iDEBUG_PARA_BUSY(iDEBUG_PARA_BUSY),
		.oDEBUG_PARA_ERROR(oDEBUG_PARA_ERROR),
		.oDEBUG_PARA_DATA(oDEBUG_PARA_DATA),
		//Output Common Interface
		.oDEBUG_COM_REQ(if2ctrl_req),
		.iDEBUG_COM_BUSY(ctrl2if_busy),
		.oDEBUG_COM_CMD(if2ctrl_cmd),
		.oDEBUG_COM_DATA(if2ctrl_data),
		.iDEBUG_COM_VALID(ctrl2if_valid),
		.oDEBUG_COM_BUSY(if2ctrl_busy),
		.iDEBUG_COM_ERROR(ctrl2if_error),
		.iDEBUG_COM_DATA(ctrl2if_data)
	);
	
	assign ctrl2if_busy = !(b_cmd_state == L_PARAM_MAIN_STT_IDLE || b_cmd_state == L_PARAM_MAIN_STT_ACTIVE) || b_ack_state != L_PARAM_CORE_ACK_STT_IDLE;
	assign ctrl2if_valid = b_ack_state == L_PARAM_CORE_ACK_STT_IF_ACK;
	assign ctrl2if_error = 1'b0;
	assign ctrl2if_data = core_buff_data;

	/****************************************************************
	Uart Command Check
	****************************************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_if_req_data <= 32'h0;
		end
		else begin
			if(b_cmd_state == L_PARAM_MAIN_STT_ACTIVE && !(iDEBUG_CMD_VALID && iDEBUG_CMD_ERROR) && interface_req_condition)begin
				b_if_req_data <= if2ctrl_data;
			end
		end
	end
			
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			if(!inRESET)begin
				b_cmd_state <= L_PARAM_MAIN_STT_IDLE;
			end
			else begin
				case(b_cmd_state)
					L_PARAM_MAIN_STT_IDLE:
						begin
							if(interface_req_condition && if2ctrl_cmd == L_PARAM_CMDCODE_AC)begin
								b_cmd_state <= L_PARAM_MAIN_STT_ACTIVE;
							end
						end
					L_PARAM_MAIN_STT_ACTIVE:
						begin
							//Error Check
							if(iDEBUG_CMD_VALID && iDEBUG_CMD_ERROR)begin
								b_cmd_state <= L_PARAM_MAIN_STT_ERROR;
							end
							//Request Check
							else if(interface_req_condition)begin	
								if(if2ctrl_cmd == L_PARAM_MAIN_STT_IDLE)begin
									b_cmd_state <= L_PARAM_MAIN_STT_IDLE;
								end
								else if(if2ctrl_cmd == L_PARAM_CMDCODE_NP)begin
									b_cmd_state <= L_PARAM_MAIN_STT_NOP;
								end
								else if(if2ctrl_cmd == L_PARAM_CMDCODE_RR)begin
									b_cmd_state <= L_PARAM_MAIN_STT_REGISTER_READ;
								end
								else if(if2ctrl_cmd == L_PARAM_CMDCODE_RW)begin
									b_cmd_state <= L_PARAM_MAIN_STT_REGISTER_WRITE;
								end
								else if(if2ctrl_cmd == L_PARAM_CMDCODE_SE)begin
									b_cmd_state <= L_PARAM_MAIN_STT_STEP_EXECUTE;
								end
								else if(if2ctrl_cmd == L_PARAM_CMDCODE_BE)begin
									b_cmd_state <= L_PARAM_MAIN_STT_BREAK_EXECUTE;
								end
								else if(if2ctrl_cmd == L_PARAM_CMDCODE_SB)begin
									b_cmd_state <= L_PARAM_MAIN_STT_SET_BREAK_POINT;
								end
							end
						end
					L_PARAM_MAIN_STT_NOP:
						begin
							b_cmd_state <= L_PARAM_MAIN_STT_ACTIVE;
						end
					L_PARAM_MAIN_STT_REGISTER_READ:
						begin
							if(!iDEBUG_CMD_BUSY)begin
								b_cmd_state <= L_PARAM_MAIN_STT_ACTIVE;
							end
						end
					L_PARAM_MAIN_STT_REGISTER_WRITE:
						begin
							if(!iDEBUG_CMD_BUSY)begin
								b_cmd_state <= L_PARAM_MAIN_STT_ACTIVE;
							end
						end
					L_PARAM_MAIN_STT_STEP_EXECUTE:
						begin
							if(!iDEBUG_CMD_BUSY)begin
								b_cmd_state <= L_PARAM_MAIN_STT_ACTIVE;
							end
						end
					L_PARAM_MAIN_STT_BREAK_EXECUTE:
						begin
							if(!iDEBUG_CMD_BUSY)begin
								b_cmd_state <= L_PARAM_MAIN_STT_ACTIVE;
							end
						end
					L_PARAM_MAIN_STT_SET_BREAK_POINT:
						begin
							if(!iDEBUG_CMD_BUSY)begin
								b_cmd_state <= L_PARAM_MAIN_STT_ACTIVE;
							end
						end
					L_PARAM_MAIN_STT_ERROR:
						begin
							b_cmd_state <= L_PARAM_MAIN_STT_IDLE;
						end
					default:
						begin
							b_cmd_state <= L_PARAM_MAIN_STT_IDLE;
						end
				endcase
			end
		end
	end //CMD State

	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin	
			b_ack_state <= L_PARAM_CORE_ACK_STT_IDLE;
		end
		else begin
			case(b_ack_state)
				L_PARAM_CORE_ACK_STT_IDLE:
					begin
						if(ack_state_start_condition)begin
							b_ack_state <= L_PARAM_CORE_ACK_STT_WAIT;
						end
					end
				L_PARAM_CORE_ACK_STT_WAIT:
					begin
						if(iDEBUG_CMD_VALID)begin
							b_ack_state <= L_PARAM_CORE_ACK_STT_IF_ACK;
						end
					end
				L_PARAM_CORE_ACK_STT_IF_ACK:
					begin
						b_ack_state <= L_PARAM_CORE_ACK_STT_IDLE;
					end
			endcase
		end
	end
	
	

	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			core_buff_error <= 1'b0;
			core_buff_data <= 32'h0;
		end
		else begin	
			if(iDEBUG_CMD_VALID)begin
				core_buff_error <= iDEBUG_CMD_ERROR;
				core_buff_data <= iDEBUG_CMD_DATA;
			end
		end
	end
	
	always @* begin
		if(!iDEBUG_CMD_BUSY)begin
			case(b_cmd_state)
				L_PARAM_MAIN_STT_REGISTER_READ:
					begin
						core_req_req =  1'b1;
						core_req_cmd = CORE_DEBUG_CMD_READ_REG;
						core_req_data = b_if_req_data;
					end
				L_PARAM_MAIN_STT_REGISTER_WRITE:
					begin
						core_req_req =  1'b1;
						core_req_cmd = CORE_DEBUG_CMD_WRITE_REG;
						core_req_data = b_if_req_data;
					end
				L_PARAM_MAIN_STT_STEP_EXECUTE:
					begin
						core_req_req =  1'b1;
						core_req_cmd = CORE_DEBUG_CMD_SINGLESTEP_CORE;
						core_req_data = b_if_req_data;
					end
				L_PARAM_MAIN_STT_BREAK_EXECUTE:
					begin
						core_req_req =  1'b1;
						core_req_cmd = CORE_DEBUG_CMD_GO_CORE;
						core_req_data = b_if_req_data;
					end
				L_PARAM_MAIN_STT_SET_BREAK_POINT:
					begin
						core_req_req =  1'b1;
						core_req_cmd = CORE_DEBUG_CMD_GO_CORE;
						core_req_data = b_if_req_data;
					end
				default:
					begin
						core_req_req =  1'b0;
						core_req_cmd = 4'h0;
						core_req_data = 32'h0;
					end
			endcase
		end
		else begin
			core_req_req =  1'b0;
			core_req_cmd = 4'h0;
			core_req_data = 32'h0;
		end
	end
		
	
	
	
	assign oDEBUG_CMD_REQ = core_req_req;
	assign oDEBUG_CMD_COMMAND = core_req_cmd;
	assign oDEBUG_CMD_TARGET = core_req_data[7:0];//b_main_counter;
	assign oDEBUG_CMD_DATA = 32'h0;
	
	
endmodule


`default_nettype wire

