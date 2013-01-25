

`default_nettype none

module processor_debugger_uart_transmit_format #(
		parameter START_DATA_EN = 1'b1,
		parameter SPRIT_DATA_EN = 1'b1,
		parameter STOP_DATA_EN = 1'b1,
		parameter START_DATA = 8'h24,	//$
		parameter SPRIT_DATA = 8'h2C,	//,
		parameter STOP_DATA = 8'h24		//\n	//8'h26	//&
		//parameter SEND_DATAMODE = 1'b1	//0:Binary 1:ASCII
	)(
		input iCLOCK,
		input inRESET,
		//
		input iTXD_REQ,
		output oTXD_BUSY,
		input iTXD_START_EN,
		input iTXD_SPLIT_EN,
		input iTXD_STOP_EN,
		input [31:0] iTXD_DATA,
		//Uart 
		output oUART_REQ,
		input iUART_BUSY,
		output [7:0] oUART_DATA
	);
	
	
	//ASCII Mode
	wire [7:0] request_send_data[0:7];
	
	assign request_send_data[0] = (b_main_data[31:28] >= 4'hA)? b_main_data[31:28] + 8'h37 : b_main_data[31:28] + 8'h30;
	assign request_send_data[1] = (b_main_data[27:24] >= 4'hA)? b_main_data[27:24] + 8'h37 : b_main_data[27:24] + 8'h30;
	assign request_send_data[2] = (b_main_data[23:20] >= 4'hA)? b_main_data[23:20] + 8'h37 : b_main_data[23:20] + 8'h30;
	assign request_send_data[3] = (b_main_data[19:16] >= 4'hA)? b_main_data[19:16] + 8'h37 : b_main_data[19:16] + 8'h30;
	assign request_send_data[4] = (b_main_data[15:12] >= 4'hA)? b_main_data[15:12] + 8'h37 : b_main_data[15:12] + 8'h30;
	assign request_send_data[5] = (b_main_data[11:8] >= 4'hA)? b_main_data[11:8] + 8'h37 : b_main_data[11:8] + 8'h30;
	assign request_send_data[6] = (b_main_data[7:4] >= 4'hA)? b_main_data[7:4] + 8'h37 : b_main_data[7:4] + 8'h30;
	assign request_send_data[7] = (b_main_data[3:0] >= 4'hA)? b_main_data[3:0] + 8'h37 : b_main_data[3:0] + 8'h30;
	
	
	
	localparam L_PARAM_MAIN_STT_IDLE = 3'h0;
	localparam L_PARAM_MAIN_STT_START_CODE = 3'h1;
	localparam L_PARAM_MAIN_STT_DATA = 3'h2;
	localparam L_PARAM_MAIN_STT_SPLIT_CODE = 3'h3;
	localparam L_PARAM_MAIN_STT_STOP_CODE = 3'h4;

	reg [2:0] b_main_state;
	reg [2:0] b_main_next_state;
	reg b_main_wait;
	reg [3:0] b_main_counter;
	
	reg [31:0] b_main_data;
	reg b_main_split_en;
	reg b_main_stop_code_en;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_state <= L_PARAM_MAIN_STT_IDLE;
			b_main_next_state <= 3'h0;
			b_main_wait <= 1'b0;
			b_main_counter <= 4'h0;
			b_main_data <= 32'h0;
			b_main_split_en <= 1'b0;
			b_main_stop_code_en <= 1'b0;
		end
		else if(b_main_wait)begin
			if(!iUART_BUSY)begin
				b_main_wait = 1'b0;
				b_main_state <= b_main_next_state;
			end
		end
		else begin
			case(b_main_state)
				L_PARAM_MAIN_STT_IDLE:
					begin
						if(iTXD_REQ)begin
							b_main_counter <= 4'h0;
							b_main_data <= iTXD_DATA;
							if(iTXD_START_EN)begin
								b_main_state <= L_PARAM_MAIN_STT_START_CODE;
							end
							else begin
								b_main_state <= L_PARAM_MAIN_STT_DATA;
							end
							b_main_split_en <= iTXD_SPLIT_EN;
							b_main_stop_code_en <= iTXD_STOP_EN;
						end
					end
				L_PARAM_MAIN_STT_START_CODE:
					begin
						b_main_counter <= 4'h0;
						b_main_wait <= 1'b1;
						b_main_next_state <= L_PARAM_MAIN_STT_DATA;
					end
				L_PARAM_MAIN_STT_DATA:
					begin
						if(b_main_counter < 4'd7)begin
							b_main_wait <= 1'b1;
							b_main_next_state <= L_PARAM_MAIN_STT_DATA;
							b_main_counter <= b_main_counter + 4'h1;
						end
						else begin
							b_main_counter <= b_main_counter + 4'h1;
							b_main_wait <= 1'b1;
							if(b_main_split_en)begin
								b_main_next_state <= L_PARAM_MAIN_STT_SPLIT_CODE;
							end
							else if(b_main_stop_code_en)begin
								b_main_next_state <= L_PARAM_MAIN_STT_STOP_CODE;
							end
							else begin
								b_main_next_state <= L_PARAM_MAIN_STT_IDLE;
							end
						end
					end
				L_PARAM_MAIN_STT_SPLIT_CODE:
					begin
						b_main_wait <= 1'b1;
						b_main_counter <= 4'h0;
						if(b_main_stop_code_en)begin
							b_main_next_state <= L_PARAM_MAIN_STT_STOP_CODE;
						end
						else begin
							b_main_next_state <= L_PARAM_MAIN_STT_IDLE;
						end
					end
				L_PARAM_MAIN_STT_STOP_CODE:
					begin
						b_main_counter <= 4'h0;
						b_main_wait <= 1'b1;
						b_main_next_state <= L_PARAM_MAIN_STT_IDLE;
					end
			endcase
		end
	end
	
	assign oTXD_BUSY = (b_main_state == L_PARAM_MAIN_STT_IDLE && !b_main_wait)? 1'b0 : 1'b1;
	assign oUART_REQ = (b_main_state != L_PARAM_MAIN_STT_IDLE)? !b_main_wait : 1'b0;
	reg [7:0] uart_send_data;
	always @*begin
		case(b_main_state)
			L_PARAM_MAIN_STT_START_CODE:
				begin
					uart_send_data = START_DATA;
				end
			L_PARAM_MAIN_STT_SPLIT_CODE:
				begin
					uart_send_data = SPRIT_DATA;
				end
			L_PARAM_MAIN_STT_STOP_CODE:
				begin
					uart_send_data = STOP_DATA;
				end
			default:
				begin
					uart_send_data = request_send_data[b_main_counter[2:0]];
				end
		endcase
	end
	assign oUART_DATA = uart_send_data;
	
	
endmodule

	
`default_nettype wire 
