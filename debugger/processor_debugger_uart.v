`default_nettype none


module processor_debugger_uart #(
		parameter BAUDRATE_COUNTER = 13'h1458	//Clock / Baudrate
	)(
		//Clock
		input iCLOCK,
		input inRESET,
		//Request
		input iTX_REQ,
		output oTX_BUSY,
		input [7:0] iTX_DATA,	
		output oRX_VALID,
		output [7:0] oRX_DATA,
		//UART
		output oUART_TXD,
		input iUART_RXD
	);	

	
	
	
	/**************************************************************
	Tx and Rx Common Define
	**************************************************************/
	localparam IDLE = 1'b0;
	localparam WORKING = 1'b1;
	

	
	/**************************************************************
	Tx Module
	**************************************************************/
	reg					b_tx_state;
	reg		[7:0]		b_tx_buffer;
	reg		[3:0]		b_tx_counter;
	

	assign				oUART_TXD		=		(b_tx_state == IDLE)? 1'b1 : func_txd(b_tx_counter, b_tx_buffer);
	assign oTX_BUSY = (b_tx_state == IDLE)? 1'b0 : 1'b1;
	
	function func_txd;
		input	[3:0]		func_counter;
		input	[7:0]		func_data;
		begin
			case(func_counter)
				4'h0:	func_txd	=	1'b0;
				4'h1:	func_txd	=	func_data[7];
				4'h2:	func_txd	=	func_data[6];
				4'h3:	func_txd	=	func_data[5];
				4'h4:	func_txd	=	func_data[4];
				4'h5:	func_txd	=	func_data[3];
				4'h6:	func_txd	=	func_data[2];
				4'h7:	func_txd	=	func_data[1];
				4'h8:	func_txd	=	func_data[0];
				4'h9:	func_txd	=	1'b1;
			endcase
		end
	endfunction
				
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_tx_state		<=		IDLE;
			b_tx_buffer		<=		8'h0;
			b_tx_counter	<=		4'h0;
		end
		else begin
			case(b_tx_state)
				IDLE:
					begin
						if(iTX_REQ)begin
							b_tx_state		<=		WORKING;
							b_tx_buffer		<=		{iTX_DATA[0], iTX_DATA[1], iTX_DATA[2], iTX_DATA[3], 
													iTX_DATA[4], iTX_DATA[5], iTX_DATA[6], iTX_DATA[7]};
						end
						b_tx_counter	<=		4'h0;
					end
				WORKING:
					begin
						if(b_bd_enable)begin
							if(b_tx_counter == 4'h9)begin
								b_tx_state		<=		IDLE;
							end
							else begin
								b_tx_counter	<=		b_tx_counter + 4'h1;
							end
						end
					end
			endcase
		end
	end
	
	
	/**************************************************************
	Rx Module
	**************************************************************/	
	assign		oRX_VALID		=		b_rx_end;
	assign		oRX_DATA		=		{b_rx_buffer[0], b_rx_buffer[1], b_rx_buffer[2], b_rx_buffer[3], 
											b_rx_buffer[4], b_rx_buffer[5], b_rx_buffer[6], b_rx_buffer[7]};
	
	
	reg b_rx_state;
	reg [7:0] b_rx_buffer;
	reg [3:0] b_rx_counter;
	reg b_rx_end;
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_rx_state		<=		IDLE;
			b_rx_buffer		<=		8'h0;
			b_rx_counter	<=		4'h0;
			b_rx_end		<=		1'b0;
		end
		else if(b_rx_end)begin
			b_rx_end <= 1'b0;
		end
		else begin
			if(b_bd_enable)begin
				case(b_rx_state)
					IDLE:
						begin
							if(iUART_RXD == 1'b0)begin
								b_rx_state		<=		WORKING;
							end
							b_rx_end		<=		1'b0;
							b_rx_counter	<=		4'h0;
						end
					WORKING:
						begin
							if(b_rx_counter == 4'h9)begin
								b_rx_state		<=		IDLE;
								b_rx_end		<=		1'b1;
							end
							else begin	
								if(b_rx_counter < 4'h9)begin
									b_rx_buffer		<=		{b_rx_buffer, iUART_RXD};
								end
								b_rx_counter	<=		b_rx_counter + 4'h1;
							end
						end
				endcase
			end
		end
	end
	
	
	/**************************************************************
	Baudrate Counter
	**************************************************************/
	reg [12:0]  b_bd_wait_counter;
	reg b_bd_enable;
	always@(posedge iCLOCK or negedge inRESET)begin	
		if(!inRESET)begin
			b_bd_wait_counter <= 13'h0;
			b_bd_enable <= 1'b0;
		end
		else begin
			if(b_bd_wait_counter == BAUDRATE_COUNTER)begin
				b_bd_wait_counter <= 13'h0;
				b_bd_enable <= 1'b1;
			end
			else begin
				b_bd_wait_counter <= b_bd_wait_counter + 13'h1;
				b_bd_enable <= 1'b0;
			end
		end
	end
	
endmodule

`default_nettype wire

	
