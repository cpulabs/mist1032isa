`default_nettype none



module dps_uart(
						//Clock
						input			iCLOCK,
						input			inRESET,
						//Request
						input			iTX_EN,
						input			iTX_REQ,
						output			oTX_BUSY,
						input	[7:0]	iTX_DATA,	
						input			iRX_EN,
						input			iRX_REQ,
						output			oRX_EMPTY,
						output	[7:0]	oRX_DATA,
						//IRQ
						output			oIRQ_VALID,
						//UART
						output			oUART_TXD,
						input			iUART_RXD
	);


	parameter BAUDRATE_VALUE = 16'd5208;
	

	
	//Baudrate Counter
	reg [15:0] b_baudrate_counter;
	reg b_baudrate_enable;
	//FIFO
	wire [7:0] txd_fifo2state_data;
	wire txd_fifo2state_empty;
	wire rxd_fifo2state_full;
	//Transmiter
	reg [3:0] b_txd_state;
	reg [7:0] b_txd_data;
	//Receiver
	reg [3:0] b_rxd_state;
	reg [7:0] b_rxd_data;
	
	
	
	
	
	
	/*********************************************
	* Baudrate Enable
	*********************************************/
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_baudrate_counter <= 16'h0;
			b_baudrate_enable <= 1'b0;
		end
		else begin
			if(BAUDRATE_VALUE == b_baudrate_counter)begin
				b_baudrate_counter <= 16'h0;
				b_baudrate_enable <= 1'b1;
			end
			else begin
				b_baudrate_counter <= b_baudrate_counter + 16'h1;
				b_baudrate_enable <= 1'b0;
			end
		end
	end //Baudrate Counter 
	
	
	/*********************************************
	* IO FIFO
	*********************************************/
	
	sync_fifo #(8, 16, 4) TX_FIFO(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(1'b0),
		.oCOUNT(),
		//WR
		.iWR_EN(iTX_EN && iTX_REQ),
		.iWR_DATA(iTX_DATA),
		.oWR_FULL(oTX_BUSY),
		//RD
		.iRD_EN(b_txd_state == TXD_STATE_IDLE),
		.oRD_DATA(txd_fifo2state_data),
		.oRD_EMPTY(txd_fifo2state_empty)
	);
	
	sync_fifo #(8, 16, 4) RX_FIFO(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(1'b0),
		.oCOUNT(),
		//WR
		.iWR_EN(b_rxd_state == RXD_STATE_STOP_BIT && !rxd_fifo2state_full),
		.iWR_DATA(b_rxd_data),
		.oWR_FULL(rxd_fifo2state_full),
		//RD
		.iRD_EN(iRX_EN && iRX_REQ),
		.oRD_DATA(oRX_DATA),
		.oRD_EMPTY(oRX_EMPTY)
	);

	
	/*********************************************
	* Transmit State
	*********************************************/
	localparam TXD_STATE_IDLE = 4'h0;
	localparam TXD_STATE_STATE_BIT = 4'h1;
	localparam TXD_STATE_DATA0 = 4'h2;
	localparam TXD_STATE_DATA1 = 4'h3;
	localparam TXD_STATE_DATA2 = 4'h4;
	localparam TXD_STATE_DATA3 = 4'h5;
	localparam TXD_STATE_DATA4 = 4'h6;
	localparam TXD_STATE_DATA5 = 4'h7;
	localparam TXD_STATE_DATA6 = 4'h8;
	localparam TXD_STATE_DATA7 = 4'h9;
	localparam TXD_STATE_STOP_BIT = 4'hA;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_txd_state <= 4'h0;
			b_txd_data <= 8'h0;
		end
		else begin
			case(b_txd_state)
				TXD_STATE_IDLE:
					begin
						if(txd_fifo2state_empty)begin
							b_txd_state <= TXD_STATE_STATE_BIT;
							b_txd_data <= txd_fifo2state_data;
						end
					end
				TXD_STATE_STATE_BIT:
					begin
						if(b_baudrate_enable)begin
							b_txd_state <= TXD_STATE_DATA0;
						end
					end
				TXD_STATE_DATA0, 
				TXD_STATE_DATA1,
				TXD_STATE_DATA2,
				TXD_STATE_DATA3,
				TXD_STATE_DATA4,
				TXD_STATE_DATA5,
				TXD_STATE_DATA6,
				TXD_STATE_DATA7:
					begin
						if(b_baudrate_enable)begin
							b_txd_state <= b_txd_state + 4'h1;
						end
					end
				TXD_STATE_STOP_BIT:
					begin
						if(b_baudrate_enable)begin
							b_txd_state <= TXD_STATE_IDLE;
						end
					end
				default:
					begin
						b_txd_state <= TXD_STATE_IDLE;
					end
			endcase
		end
	end //TXD State
	
	/*********************************************
	* Receiver State
	*********************************************/
	localparam RXD_STATE_IDLE = 4'h0;
	localparam RXD_STATE_DATA0 = 4'h1;
	localparam RXD_STATE_DATA1 = 4'h2;
	localparam RXD_STATE_DATA2 = 4'h3;
	localparam RXD_STATE_DATA3 = 4'h4;
	localparam RXD_STATE_DATA4 = 4'h5;
	localparam RXD_STATE_DATA5 = 4'h6;
	localparam RXD_STATE_DATA6 = 4'h7;
	localparam RXD_STATE_DATA7 = 4'h8;
	localparam RXD_STATE_STOP_BIT = 4'h9;
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_rxd_state <= 4'h0;
			b_rxd_data <= 8'h0;
		end
		else begin
			case(b_rxd_state)
				RXD_STATE_IDLE:
					begin
						if(!iUART_RXD && b_baudrate_enable)begin
							b_rxd_state <= RXD_STATE_DATA0;
						end
					end
				RXD_STATE_DATA0, 
				RXD_STATE_DATA1,
				RXD_STATE_DATA2,
				RXD_STATE_DATA3,
				RXD_STATE_DATA4,
				RXD_STATE_DATA5,
				RXD_STATE_DATA6,
				RXD_STATE_DATA7:
					begin
						if(b_baudrate_enable)begin
							b_rxd_state <= b_rxd_state + 4'h1;
							b_rxd_data <= {b_rxd_data[6:0], iUART_RXD};
						end
					end
				RXD_STATE_STOP_BIT:
					begin
						if(b_baudrate_enable)begin
							b_rxd_state <= RXD_STATE_IDLE;
						end
					end
				default:
					begin
						b_rxd_state <= RXD_STATE_IDLE;
					end
			endcase
		end
	end //RXD State

	
	/*********************************************
	* Assign
	*********************************************/
	reg uart_tr_single;
	always @* begin
		case(b_txd_state)
			TXD_STATE_IDLE : uart_tr_single = 1'b1;
			TXD_STATE_STATE_BIT : uart_tr_single = 1'b0;
			TXD_STATE_DATA0 : uart_tr_single = b_txd_data[7];
			TXD_STATE_DATA1 : uart_tr_single = b_txd_data[6];
			TXD_STATE_DATA2 : uart_tr_single = b_txd_data[5];
			TXD_STATE_DATA3 : uart_tr_single = b_txd_data[4];
			TXD_STATE_DATA4 : uart_tr_single = b_txd_data[3];
			TXD_STATE_DATA5 : uart_tr_single = b_txd_data[2];
			TXD_STATE_DATA6 : uart_tr_single = b_txd_data[1];
			TXD_STATE_DATA7 : uart_tr_single = b_txd_data[0];
			TXD_STATE_STOP_BIT : uart_tr_single = 1'b1;
			default : uart_tr_single = 1'b1;
		endcase
	end
	assign oUART_TXD = uart_tr_single;
	
	assign oIRQ_VALID = (b_rxd_state == RXD_STATE_STOP_BIT);
		
endmodule



`default_nettype wire

	
