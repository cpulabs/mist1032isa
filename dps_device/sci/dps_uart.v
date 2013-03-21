`default_nettype none

/* Baudrate Select
	0x0		:	9600 (Reset After)
	0x1		:	110
	0x2		:	300
	0x3		:	600
	0x4		:	1200
	0x5		:	2400
	0x6		:	4800
	0x7		:	14400
	0x8		:	19200
	0x9		:	38400
	0xA		:	57600
	0xB		:	115200
	0xC		:	230400
	0xD		:	460800
	0xE		:	921600
	0xF		:	Reserved
*/



module dps_uart(
		//Clock
		input iCLOCK,
		input inRESET,
		//Baudrate
		input [3:0] iBAUDRATE,
		//Transmit
		input iTX_EN,
		input iTX_CLEAR,
		input iTX_REQ,
		output oTX_BUSY,
		input [7:0] iTX_DATA,
		output [3:0] oTX_BUFF_CNT,
		output oTX_TRANSMIT,
		//Receive
		input iRX_EN,
		input iRX_CLEAR,
		input iRX_REQ,
		output oRX_EMPTY,
		output [7:0] oRX_DATA,
		output [3:0] oRX_BUFF_CNT,
		output oRX_RECEIVE,
		//IRQ
		output oIRQ_VALID,
		//UART
		output oUART_TXD,
		input iUART_RXD
	);
	
	
	/*********************************************
	* Baudrate Enable
	*********************************************/
	reg [18:0] baudrate_compare;
	always @* begin
		case(iBAUDRATE)
			4'h0: baudrate_compare <= 19'd1302;		//9600
			4'h1: baudrate_compare <= 19'd113636;	//110
			4'h2: baudrate_compare <= 19'd166666;	//300
			4'h3: baudrate_compare <= 19'd41666;	//600
			4'h4: baudrate_compare <= 19'd41666;	//1200
			4'h5: baudrate_compare <= 19'd10416;	//2400
			4'h6: baudrate_compare <= 19'd2604;		//4800
			4'h7: baudrate_compare <= 19'd868;		//14400
			4'h8: baudrate_compare <= 19'd2604;		//19200
			4'h9: baudrate_compare <= 19'd651;		//38400
			4'hA: baudrate_compare <= 19'd217;		//57600
			4'hB: baudrate_compare <= 19'd108;		//115200
			4'hC: baudrate_compare <= 19'd54;		//230400
			4'hD: baudrate_compare <= 19'd27;		//460800
			4'hE: baudrate_compare <= 19'd11;		//921600
			default: baudrate_compare <= 19'd1302;	//9600
		endcase
	end
	
	/*********************************************
	* Uart FIFO
	*********************************************/
	
	wire transmitter_tx_enable;
	wire transmitter_tx_busy;
	wire [7:0] transmitter_tx_data;
	
	wire receiver_rx_enable;
	wire receiver_rx_busy;
	wire [7:0] receiver_rx_data;
	
	sync_fifo #(8, 16, 4) TX_FIFO(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(iTX_CLEAR),
		.oCOUNT(oTX_BUFF_CNT),
		//WR
		.iWR_EN(iTX_EN && iTX_REQ),
		.iWR_DATA(iTX_DATA),
		.oWR_FULL(oTX_BUSY),
		//RD
		.iRD_EN(!transmitter_tx_enable && !transmitter_tx_busy),
		.oRD_DATA(transmitter_tx_data),
		.oRD_EMPTY(transmitter_tx_enable)
	);
	
	sync_fifo #(8, 16, 4) RX_FIFO(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(iRX_CLEAR),
		.oCOUNT(oRX_BUFF_CNT),
		//WR
		.iWR_EN(receiver_rx_enable && !receiver_rx_busy),
		.iWR_DATA(receiver_rx_data),
		.oWR_FULL(receiver_rx_busy),
		//RD
		.iRD_EN(iRX_EN && iRX_REQ),
		.oRD_DATA(oRX_DATA),
		.oRD_EMPTY(oRX_EMPTY)
	);
	
	
	
	/*********************************************
	* Uart Transmitter
	*********************************************/
	uart_transmitter #(1'b0, 20'd108) UART_TRANSMITTER(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//External Baudrate Timing
		.iEXTBAUD_COUNT({1'b0, baudrate_compare}),
		//Request
		.iTX_REQ(!transmitter_tx_enable && !transmitter_tx_busy),
		.oTX_BUSY(transmitter_tx_busy),
		.iTX_DATA(transmitter_tx_data),
		//UART
		.oUART_TXD(oUART_TXD)
	);
	
	/*********************************************
	* Uart Receiver
	*********************************************/
	uart_receiver #(1'b0, 20'd108) UART_RECEIVER(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//External Baudrate Timing
		.iEXTBAUD_COUNT({1'b0, baudrate_compare}),
		//R Data	
		.oRX_VALID(receiver_rx_enable),
		.oRX_DATA(receiver_rx_data),
		//UART
		.iUART_RXD(iUART_RXD)
	);
	
	/*********************************************
	* Assign
	*********************************************/
	assign oTX_TRANSMIT = !transmitter_tx_enable && !transmitter_tx_busy;
	assign oRX_RECEIVE = receiver_rx_enable;

	
endmodule



module dps_uart___(
		//Clock
		input iCLOCK,
		input inRESET,
		//Request
		input [3:0] iBAUDRATE,
		input iTX_EN,
		input iTX_CLEAR,
		input iTX_REQ,
		output oTX_BUSY,
		input [7:0] iTX_DATA,
		output [3:0] oTX_BUFF_CNT,
		output oTX_TRANSMIT,
		input iRX_EN,
		input iRX_CLEAR,
		input iRX_REQ,
		output oRX_EMPTY,
		output [7:0] oRX_DATA,
		output [3:0] oRX_BUFF_CNT,
		output oRX_RECEIVE,
		//IRQ
		output oIRQ_VALID,
		//UART
		output oUART_TXD,
		input iUART_RXD
	);

	//Baudrate Counter
	reg [18:0] b_baudrate_counter;
	reg b_baudrate_enable;
	//FIFO
	wire [7:0] txd_fifo2state_data;
	wire txd_fifo2state_empty;
	wire [3:0] txd_fifo2state_fifo_count;
	wire rxd_fifo2state_full;
	wire [3:0] rxd_fifo2state_fifo_count;
	//Transmiter
	reg [3:0] b_txd_state;
	reg [7:0] b_txd_data;
	//Receiver
	reg [3:0] b_rxd_state;
	reg [7:0] b_rxd_data;
	
	
	/*********************************************
	* Baudrate Enable
	*********************************************/
	reg [18:0] baudrate_compare;
	always @* begin
		case(iBAUDRATE)
			4'h0: baudrate_compare <= 19'd5208;		//9600
			4'h1: baudrate_compare <= 19'd454545;	//110
			4'h2: baudrate_compare <= 19'd166666;	//300
			4'h3: baudrate_compare <= 19'd83333;	//600
			4'h4: baudrate_compare <= 19'd41666;	//1200
			4'h5: baudrate_compare <= 19'd20833;	//2400
			4'h6: baudrate_compare <= 19'd10416;	//4800
			4'h7: baudrate_compare <= 19'd3472;		//14400
			4'h8: baudrate_compare <= 19'd2604;		//19200
			4'h9: baudrate_compare <= 19'd1302;		//38400
			4'hA: baudrate_compare <= 19'd868;		//57600
			4'hB: baudrate_compare <= 19'd434;		//115200
			4'hC: baudrate_compare <= 19'd217;		//230400
			4'hD: baudrate_compare <= 19'd109;		//460800
			4'hE: baudrate_compare <= 19'd45;		//921600
			default: baudrate_compare <= 19'd5208;	//9600
		endcase
	end
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_baudrate_counter <= 19'h0;
			b_baudrate_enable <= 1'b0;
		end
		else begin
			if(baudrate_compare == b_baudrate_counter)begin
				b_baudrate_counter <= 19'h0;
				b_baudrate_enable <= 1'b1;
			end
			else begin
				b_baudrate_counter <= b_baudrate_counter + 19'h1;
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
		.iREMOVE(iTX_CLEAR),
		.oCOUNT(txd_fifo2state_fifo_count),
		//WR
		.iWR_EN(iTX_EN && iTX_REQ),
		.iWR_DATA(iTX_DATA),
		.oWR_FULL(oTX_BUSY),
		//RD
		.iRD_EN(!txd_fifo2state_empty && b_txd_state == TXD_STATE_IDLE),
		.oRD_DATA(txd_fifo2state_data),
		.oRD_EMPTY(txd_fifo2state_empty)
	);
	
	sync_fifo #(8, 16, 4) RX_FIFO(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(iRX_CLEAR),
		.oCOUNT(rxd_fifo2state_fifo_count),
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
						if(!txd_fifo2state_empty)begin
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
	
	assign oTX_TRANSMIT = (b_txd_state == TXD_STATE_STOP_BIT);
	
	assign oRX_RECEIVE = (b_rxd_state == RXD_STATE_STOP_BIT);
	
	assign oTX_BUFF_CNT = txd_fifo2state_fifo_count;
	
	assign oRX_BUFF_CNT = rxd_fifo2state_fifo_count;
		
endmodule



`default_nettype wire

	
